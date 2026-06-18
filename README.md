# OpenCode Agent Suite

Wiederverwendbare **Agents**, **Rules** und **Skills** für [OpenCode](https://opencode.ai) — orchestriert über den **Coordinator** als zentrale Schnittstelle für Research, Planung, Audit und Ausführung.

## Architektur

```mermaid
flowchart TB
    User([Nutzer]) --> Coordinator

    Coordinator --> Researcher
    Coordinator --> SoftwareEngineer[Software Engineer]
    Coordinator --> DevOps[DevOps Engineer]
    Coordinator --> SecurityAuditor[Security Auditor]
    Coordinator --> CodeReviewer[Code Reviewer]
    Coordinator --> QA[QA Automation Engineer]

    Coordinator --> BugAuditSkill[parallel-bug-audit Skill]
    BugAuditSkill --> Researcher

    Rules[".opencode/rules/"] --> Coordinator
    Rules --> SoftwareEngineer
    Skills[".opencode/skills/"] --> Coordinator
```

**Grundprinzip:** Starte **immer** mit `@Coordinator`. Er untersucht, plant, delegiert und verifiziert — du sprichst nicht direkt mit Implementierungs-Subagents, außer für gezielte Read-only-Research.

| Komponente             | Rolle                                                 |
| ---------------------- | ----------------------------------------------------- |
| **Coordinator**        | Primary Agent — zentrale Schnittstelle für alles      |
| **Researcher**         | Read-only Subagent für Codebase-Recherche             |
| **parallel-bug-audit** | Skill für parallele Bug-/Gap-Audits via Researcher    |
| **Rules**              | Projektweite Coding-Konventionen                      |
| **Weitere Subagents**  | Software Engineer, Code Reviewer, Security Auditor, … |

---

## Voraussetzungen

1. [OpenCode installiert](https://opencode.ai/docs) (Terminal, Desktop oder IDE)
2. Mindestens ein LLM-Provider konfiguriert (`/connect` in der TUI)
3. Git-Repository für dein Zielprojekt

---

## Installation

Es gibt zwei Wege: **global** (alle Projekte) oder **projektspezifisch** (empfohlen für Teams).

### Option A — Projektspezifisch (empfohlen)

Im Root deines Zielprojekts:

```bash
# 1. OpenCode-Verzeichnis anlegen
mkdir -p .opencode/agents .opencode/rules .opencode/skills .opencode/state

# 2. Agents kopieren
cp -R /pfad/zu/opencode-agent/agents/* .opencode/agents/

# 3. Rules kopieren
cp -R /pfad/zu/opencode-agent/rules/* .opencode/rules/

# 4. Bug-Audit-Skill kopieren (Ordnername MUSS dem Skill-Namen entsprechen)
cp -R /pfad/zu/opencode-agent/bug-and-gap-audit .opencode/skills/parallel-bug-audit

# 5. Beispiel-Konfiguration übernehmen und anpassen
cp /pfad/zu/opencode-agent/opencode.json.example opencode.json
```

Alternativ per Symlink (Updates aus diesem Repo propagieren sich automatisch):

```bash
ln -s /pfad/zu/opencode-agent/agents .opencode/agents
ln -s /pfad/zu/opencode-agent/rules .opencode/rules
ln -s /pfad/zu/opencode-agent/bug-and-gap-audit .opencode/skills/parallel-bug-audit
```

### Option B — Global

Für persönliche Nutzung über alle Projekte:

```bash
mkdir -p ~/.config/opencode/agents ~/.config/opencode/skills

cp -R /pfad/zu/opencode-agent/agents/* ~/.config/opencode/agents/
cp -R /pfad/zu/opencode-agent/bug-and-gap-audit ~/.config/opencode/skills/parallel-bug-audit
```

Rules sind projektspezifisch — kopiere sie **nicht** global, sondern pro Projekt nach `.opencode/rules/`.

---

## Einrichtung im Detail

### 1. Coordinator als Default-Agent

Der Coordinator ist der **einzige Einstiegspunkt** für produktive Arbeit. Er übernimmt:

- **Research** — delegiert an `@Researcher` statt selbst den Context zu füllen
- **Planung** — schreibt Pläne nach `.opencode/state/current_plan.md`
- **Ausführung** — delegiert Tasks an Software Engineer, DevOps, …
- **Audit** — Security Auditor, Code Reviewer, Bug-Audit-Skill
- **Verifikation** — Convergence-Loops bei REJECTED Reviews

In `opencode.json`:

```json
{
  "default_agent": "Coordinator",
  "agent": {
    "build": { "disable": true },
    "plan": { "disable": true }
  }
}
```

> Built-in Agents `build` und `plan` deaktivieren, damit nicht versehentlich ohne Orchestrator gearbeitet wird. Passe Modelle in den Agent-Frontmatter-Blöcken an deine Provider an (`model: openai/gpt-5.5` → dein verfügbares Modell).

OpenCode neu starten, dann mit **Tab** prüfen, ob `Coordinator` als Primary Agent ausgewählt ist.

### 2. Researcher

Der Researcher ist ein **read-only Subagent** (`mode: all`). Er wird vom Coordinator per `task`-Tool oder manuell via `@Researcher` aufgerufen.

**Installation:** Liegt in `agents/Researcher.md` → wird nach `.opencode/agents/Researcher.md` kopiert.

**Wichtig:**

- Keine Schreibrechte — nur `read`, `grep`, `glob`, `list`
- Jede Aussage braucht `path:line`-Zitate
- Nie raten — bei fehlenden Ergebnissen: `NO RESULTS FOUND IN CODEBASE`

**Typischer Flow:**

```
@Coordinator Untersuche, wie Auth in diesem Projekt funktioniert
```

→ Coordinator delegiert an Researcher, synthetisiert den Report, plant weiter.

**Direktaufruf** (nur für isolierte Recherche ohne Planung):

```
@Researcher Wo wird JWT validiert? Zeige alle Entry Points.
```

### 3. Rules

Rules definieren Coding-Konventionen. Sie liegen in `rules/` und werden über `opencode.json` eingebunden:

```json
{
  "instructions": ["AGENTS.md", ".opencode/rules/*.md"]
}
```

Enthaltene Rules in diesem Repo:

| Datei                 | Inhalt                                            |
| --------------------- | ------------------------------------------------- |
| `code-styles.md`      | Allgemeine Code-Stil- und Architektur-Invarianten |
| `react-guidelines.md` | React-spezifische Konventionen                    |
| `testing.md`          | Test-Richtlinien                                  |

**Zusätzlich empfohlen:** Projekt-Root `AGENTS.md` via `/init` generieren lassen. OpenCode merged `AGENTS.md` + `instructions` aus `opencode.json`.

Der Coordinator und Software Engineer referenzieren Rules automatisch in Delegations-Prompts (`.opencode/rules/`, `AGENTS.md`, `docs/_invariants/`).

### 4. Bug-Audit-Skill (`parallel-bug-audit`)

Paralleler Bug-/Gap-Audit: Coordinator mappt ein Subsystem, erstellt ein Failure-Mode-Brief, dispatcht mehrere `@Researcher`-Instanzen parallel und konsolidiert die Findings.

**Installation:**

```bash
cp -R bug-and-gap-audit .opencode/skills/parallel-bug-audit
```

> Der Ordnername **muss** `parallel-bug-audit` heißen — das entspricht dem `name`-Feld in `SKILL.md`.

**Permissions in `opencode.json`:**

```json
{
  "permission": {
    "skill": {
      "parallel-bug-audit": "allow"
    },
    "task": "allow"
  }
}
```

**Aufruf** (immer über Coordinator):

```
@Coordinator Audit das Email-Sync-Subsystem auf Bugs und Gaps
```

Der Coordinator lädt den Skill, dispatcht parallel Researcher und liefert einen klassifizierten Report (Confirmed Bug / Gap / Suspected / Misleading).

**Cache-Verzeichnis** (gitignored in Zielprojekten):

```
.opencode/.cache/bug-audit/<target>-failure-modes.md
```

---

## `opencode.json` — vollständige Referenz

Kopiere `opencode.json.example` ins Projekt-Root und passe an:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "default_agent": "Coordinator",
  "instructions": ["AGENTS.md", ".opencode/rules/*.md"],
  "permission": {
    "skill": {
      "*": "allow",
      "parallel-bug-audit": "allow"
    },
    "task": "allow"
  },
  "agent": {
    "build": { "disable": true },
    "plan": { "disable": true },
    "Coordinator": {
      "permission": {
        "task": { "*": "allow" },
        "skill": { "*": "allow" }
      }
    }
  }
}
```

---

## Verzeichnisstruktur (Zielprojekt nach Setup)

```
dein-projekt/
├── AGENTS.md                          # Projekt-spezifische Regeln (/init)
├── opencode.json                      # OpenCode-Konfiguration
├── .opencode/
│   ├── agents/
│   │   ├── Coordinator.md             # Primary — immer starten
│   │   ├── Researcher.md              # Read-only Research
│   │   ├── Software Engineer.md
│   │   ├── Code Reviewer.md
│   │   ├── Security Auditor.md
│   │   └── …
│   ├── rules/
│   │   ├── code-styles.md
│   │   ├── react-guidelines.md
│   │   └── testing.md
│   ├── skills/
│   │   └── parallel-bug-audit/
│   │       ├── SKILL.md
│   │       └── references/
│   └── state/
│       └── current_plan.md            # Laufender Plan (runtime)
└── docs/
    └── _invariants/                   # Optional: projekt-spezifische Invarianten
```

---

## Workflow-Beispiele

### Feature implementieren

```
@Coordinator Implementiere User-Notifications mit WebSocket-Push
```

1. Coordinator kategorisiert (FEATURE), investigiert, schreibt Plan
2. User approved Plan
3. Coordinator delegiert Task 1 an Software Engineer
4. Security Auditor + Code Reviewer prüfen
5. Nächster Task — bis Completion Report

### Bug fixen

```
@Coordinator Der Login schlägt nach Token-Refresh fehl — finde Root Cause und fixe
```

Coordinator führt Bug Root Cause Gate durch, plant Fix am Symptom-Ursprung (nicht am Symptom).

### Subsystem auditieren

```
@Coordinator Audit src/sync/ auf echte Bugs und Gaps bevor wir refactoren
```

Coordinator lädt `parallel-bug-audit`, dispatcht 4–7 parallele Researcher, liefert deduplizierten Report.

### Schnelle Recherche (ohne Plan)

```
@Coordinator Wo wird Rate-Limiting konfiguriert? Nur Recherche, kein Code.
```

Coordinator delegiert an Researcher, gibt strukturierten Report zurück — ohne Phase 3 Execution Loop.

---

## Enthaltene Agents

| Agent                      | Mode       | Beschreibung                   |
| -------------------------- | ---------- | ------------------------------ |
| **Coordinator**            | `primary`  | Orchestriert den gesamten SDLC |
| **Researcher**             | `all`      | Read-only Codebase-Recherche   |
| **Software Engineer**      | `subagent` | Implementierung                |
| **Code Reviewer**          | `subagent` | Code-Review                    |
| **Security Auditor**       | `subagent` | Sicherheits-Audit              |
| **DevOps Engineer**        | `subagent` | Infrastruktur & CI/CD          |
| **QA Automation Engineer** | `subagent` | Test-Automatisierung           |
| **Technical Writer**       | `subagent` | Dokumentation                  |
| **Doc Reviewer**           | `subagent` | Dokumentations-Review          |
| **PRD Critic**             | `subagent` | PRD-Analyse                    |

---

## Troubleshooting

| Problem                                    | Lösung                                                                            |
| ------------------------------------------ | --------------------------------------------------------------------------------- |
| Coordinator nicht in Agent-Liste           | OpenCode neu starten; prüfen ob `.opencode/agents/Coordinator.md` existiert       |
| Skill nicht sichtbar                       | Ordner muss `parallel-bug-audit` heißen; `SKILL.md` in CAPS; OpenCode neu starten |
| Researcher kann nicht dispatched werden    | `task: allow` in Coordinator-Permissions setzen                                   |
| Rules werden ignoriert                     | `instructions` in `opencode.json` prüfen; Pfade relativ zum Projekt-Root          |
| Falsches Modell                            | `model:` in Agent-Frontmatter an verfügbare Provider anpassen                     |
| Built-in `build` startet statt Coordinator | `default_agent: "Coordinator"` setzen; `build`/`plan` disable                     |

---

## Repo-Struktur (dieses Template)

```
opencode-agent/
├── README.md
├── opencode.json.example
├── agents/                    # Alle Agent-Definitionen
├── rules/                     # Coding-Konventionen
└── bug-and-gap-audit/         # Skill-Quelle → installieren als parallel-bug-audit
    ├── SKILL.md
    └── references/
```

---

## Weiterführend

- [OpenCode Agents](https://opencode.ai/docs/agents/)
- [OpenCode Rules](https://opencode.ai/docs/rules/)
- [OpenCode Skills](https://opencode.ai/docs/skills/)
