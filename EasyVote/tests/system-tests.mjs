// ============================================================
// EasyVote — Tests SYSTÈME (E2E, boîte noire) automatisés
// Pilote la vraie API REST (backend + MariaDB démarrés).
//
// Prérequis : backend démarré + tests/seed-demo.sql chargé.
// Lancement :  node tests/system-tests.mjs
//   (autre port : set API_URL=http://localhost:8084/api && node tests/system-tests.mjs)
// ============================================================

const API = process.env.API_URL || "http://localhost:8082/api";
const PASSWORD = "password123";

let passed = 0;
let failed = 0;

function check(id, label, condition, detail = "") {
  if (condition) {
    passed++;
    console.log(`  ✅ ${id} ${label}`);
  } else {
    failed++;
    console.log(`  ❌ ${id} ${label}  ${detail}`);
  }
}

async function call(method, path, token, body) {
  const started = performance.now();
  const res = await fetch(API + path, {
    method,
    headers: {
      "Content-Type": "application/json",
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: body ? JSON.stringify(body) : undefined,
  });
  const ms = performance.now() - started;
  const type = res.headers.get("content-type") || "";
  const data = type.includes("json") ? await res.json() : Buffer.from(await res.arrayBuffer());
  return { status: res.status, data, ms, type };
}

async function login(email) {
  const r = await call("POST", "/auth/login", null, { email, password: PASSWORD });
  if (r.status !== 200) throw new Error(`Connexion impossible pour ${email} (HTTP ${r.status}) — seed chargé ?`);
  return r.data.data.accessToken;
}

// LocalDateTime attendu par Spring (heure locale, sans fuseau)
function inDays(days) {
  const d = new Date(Date.now() + days * 86_400_000);
  const p = (n) => String(n).padStart(2, "0");
  return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())}T${p(d.getHours())}:${p(d.getMinutes())}:00`;
}

console.log(`\nEasyVote — tests système sur ${API}\n`);

const admin = await login("ahmed@test.com");
const futurCandidat = await login("achref@test.com");
const electeur = await login("talel@test.com");

// ── ST-01 Scénario démo de bout en bout (CDC 7.3) ─────────────
console.log("ST-01 Scénario complet : création → candidature → validation → vote → résultats");
const creation = await call("POST", "/elections", admin, {
  title: `Élection BDE (test système ${new Date().toISOString()})`,
  description: "Créée par system-tests.mjs",
  campaignStart: inDays(1),
  campaignEnd: inDays(2),
  voteStart: inDays(2),
  voteEnd: inDays(3),
});
check("ST-01.1", "l'admin crée une élection (DRAFT)", creation.status === 201 && creation.data.data.status === "DRAFT",
  `HTTP ${creation.status}`);
const electionId = creation.data.data.id;

const campagne = await call("PATCH", `/elections/${electionId}/status`, admin, { status: "CAMPAIGN_ACTIVE" });
check("ST-01.2", "ouverture de la campagne", campagne.status === 200, `HTTP ${campagne.status}`);

const candidature = await call("POST", "/candidates/apply", futurCandidat, {
  electionId, slogan: "Un campus pour tous", program: "1. Plus de salles d'étude. 2. Wifi partout.",
});
check("ST-01.3", "un étudiant postule (PENDING)",
  candidature.status === 201 && candidature.data.data.status === "PENDING", `HTTP ${candidature.status}`);
const candidateId = candidature.data.data.id;

const validation = await call("POST", `/candidates/${candidateId}/validate`, admin, { status: "VALIDATED" });
check("ST-01.4", "l'admin valide la candidature", validation.data?.data?.status === "VALIDATED",
  `HTTP ${validation.status}`);

const vote = await call("PATCH", `/elections/${electionId}/status`, admin, { status: "VOTE_ACTIVE" });
const jetons = await call("POST", `/admin/elections/${electionId}/generate-tokens`, admin);
check("ST-01.5", "ouverture du vote + génération des jetons", vote.status === 200 && jetons.status === 200,
  `HTTP ${vote.status}/${jetons.status}`);

const bulletin = await call("POST", `/elections/${electionId}/vote`, electeur, { candidateId });
const code = bulletin.data?.data?.confirmationCode || "";
check("ST-01.6", `l'étudiant vote → code de confirmation « ${code} »`,
  bulletin.status === 201 && /^[A-Z0-9]{10}$/.test(code), `HTTP ${bulletin.status}`);

// ── ST-02 Interdiction du double vote ─────────────────────────
console.log("ST-02 Interdiction du double vote");
const second = await call("POST", `/elections/${electionId}/vote`, electeur, { candidateId });
check("ST-02", "le 2e vote est refusé avec un message clair",
  second.status >= 400 && /déjà voté/i.test(second.data?.message || ""),
  `HTTP ${second.status} « ${second.data?.message} »`);

// ── ST-03 Transparence selon le statut (CDC 3.2.3) ────────────
console.log("ST-03 Transparence : participation pendant le vote, détails après clôture");
const resEtudiantPendant = await call("GET", `/elections/${electionId}/results`, electeur);
const statsPubliques = await call("GET", `/elections/${electionId}/stats/public`, electeur);
check("ST-03.1", "pendant le vote, l'étudiant ne voit PAS les résultats détaillés", resEtudiantPendant.status >= 400,
  `HTTP ${resEtudiantPendant.status}`);
check("ST-03.2", "pendant le vote, l'étudiant voit la participation",
  statsPubliques.status === 200 && statsPubliques.data.data.totalVotes === 1, `HTTP ${statsPubliques.status}`);

await call("PATCH", `/elections/${electionId}/status`, admin, { status: "CLOSED" });
const resultats = await call("GET", `/elections/${electionId}/results`, electeur);
const premier = resultats.data?.data?.results?.[0];
check("ST-03.3", "après clôture, résultats détaillés publiés (rang 1 = 100 %)",
  resultats.status === 200 && premier?.rank === 1 && premier?.percentage === 100, `HTTP ${resultats.status}`);

const pdf = await call("GET", `/elections/${electionId}/results/pdf`, electeur);
check("ST-05", "export du rapport PDF officiel",
  pdf.status === 200 && pdf.type.includes("pdf") && pdf.data.subarray(0, 4).toString() === "%PDF",
  `HTTP ${pdf.status} ${pdf.type}`);

// ── REG-002 Non-régression du calcul des résultats ────────────
console.log("REG-002 Non-régression : résultats identiques à chaque lecture après clôture");
const relecture = await call("GET", `/elections/${electionId}/results`, electeur);
const r1 = resultats.data?.data;
const r2 = relecture.data?.data;
const figer = (r) => JSON.stringify({
  totalVotes: r?.totalVotes,
  participationRate: r?.participationRate,
  isFinal: r?.isFinal,
  results: r?.results?.map((c) => [c.candidateId, c.votes, c.percentage, c.rank]),
});
check("REG-002", "classement, votes, pourcentages et participation inchangés entre deux lectures",
  relecture.status === 200 && r1?.totalVotes === 1 && r1?.isFinal === true && figer(r1) === figer(r2),
  `HTTP ${relecture.status}`);

// ── ST-NF Performance (CDC 5.1 : lecture < 200 ms) ────────────
console.log("ST-NF Performance");
const durees = [];
for (let i = 0; i < 20; i++) durees.push((await call("GET", "/elections", electeur)).ms);
const moyenne = durees.reduce((a, b) => a + b, 0) / durees.length;
check("ST-NF", `GET /elections : moyenne ${moyenne.toFixed(1)} ms sur 20 appels (< 200 ms)`, moyenne < 200);

console.log(`\nBilan : ${passed} vérifications réussies, ${failed} en échec.\n`);
process.exit(failed > 0 ? 1 : 0);
