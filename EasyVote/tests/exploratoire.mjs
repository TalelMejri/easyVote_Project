// ============================================================
// EasyVote — Tests EXPLORATOIRES (manuels, rejoués par script)
// Vérifie 3 règles du cahier des charges repérées pendant la revue de code.
// Prérequis : backend + MySQL démarrés, tests/seed-demo.sql chargé.
// Lancement : node tests/exploratoire.mjs
// ============================================================

const API = process.env.API_URL || "http://localhost:8082/api";

async function call(method, path, token, body) {
  const res = await fetch(API + path, {
    method,
    headers: { "Content-Type": "application/json", ...(token ? { Authorization: `Bearer ${token}` } : {}) },
    body: body ? JSON.stringify(body) : undefined,
  });
  return { status: res.status, data: await res.json().catch(() => null) };
}
const login = async (email) =>
  (await call("POST", "/auth/login", null, { email, password: "password123" })).data.data.accessToken;
function inDays(days) {
  const d = new Date(Date.now() + days * 86_400_000);
  const p = (n) => String(n).padStart(2, "0");
  return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())}T${p(d.getHours())}:${p(d.getMinutes())}:00`;
}
function verdict(id, regle, attendu, obtenu, conforme) {
  console.log(`\n${id} ${regle}`);
  console.log(`   Attendu (CDC) : ${attendu}`);
  console.log(`   Obtenu        : ${obtenu}`);
  console.log(`   => ${conforme ? "✅ conforme" : "❌ NON conforme (défaut)"}`);
}

const admin = await login("ahmed@test.com");
const etudiant = await login("dali@test.com");

// L'admin crée une élection, qui reste en DRAFT (brouillon, invisible aux étudiants)
const election = (await call("POST", "/elections", admin, {
  title: `Exploratoire ${new Date().toISOString()}`,
  campaignStart: inDays(1), campaignEnd: inDays(2), voteStart: inDays(2), voteEnd: inDays(3),
})).data.data;

// EX-1 : CDC §3.1.2 — on ne postule que pendant CAMPAIGN_ACTIVE
const candidature = await call("POST", "/candidates/apply", etudiant, {
  electionId: election.id, slogan: "Test exploratoire", program: "Programme",
});
verdict("EX-1", "Postuler à une élection encore en DRAFT",
  "refus (candidature seulement en CAMPAIGN_ACTIVE)",
  `HTTP ${candidature.status} ${candidature.status === 201 ? "(candidature acceptée)" : ""}`,
  candidature.status >= 400);

// EX-2 : CDC §3.1.2 — le rôle devient CANDIDATE seulement APRÈS validation
const moi = (await call("GET", "/auth/me", etudiant)).data.data;
verdict("EX-2", "Rôle de l'étudiant dont la candidature est encore PENDING",
  "STUDENT", moi.role, moi.role === "STUDENT");

// EX-3 : CDC §6.1 — l'administrateur « ne vote pas »
const candidatId = candidature.data?.data?.id;
await call("POST", `/candidates/${candidatId}/validate`, admin, { status: "VALIDATED" });
await call("PATCH", `/elections/${election.id}/status`, admin, { status: "CAMPAIGN_ACTIVE" });
await call("PATCH", `/elections/${election.id}/status`, admin, { status: "VOTE_ACTIVE" });
const voteAdmin = await call("POST", `/elections/${election.id}/vote`, admin, { candidateId: candidatId });
verdict("EX-3", "L'administrateur essaie de voter",
  "refus (HTTP 403)", `HTTP ${voteAdmin.status} « ${voteAdmin.data?.message} »`, voteAdmin.status >= 400);

console.log("");
