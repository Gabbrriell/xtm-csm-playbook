# XTM Platform: Customer Success Playbook

A customer success playbook for Filigran's XTM Platform (OpenCTI, OpenAEV, OpenCRQ and XTM One), written to learn the suite from the customer's side: what they're trying to achieve, where they get stuck, and how to prove value at renewal.

Built from Filigran's public docs and product pages, plus a hands-on lab running the official OpenCTI + XTM One stack locally (see [Lab notes](#lab-notes)).

---

## The platform in one minute

| Module | What it does | The customer question it answers |
|---|---|---|
| **OpenCTI** | Threat intelligence platform. Stores knowledge as STIX 2.1 and pulls in feeds through connectors (MITRE ATT&CK, CISA KEV, ISACs, commercial feeds). | "Who is targeting us, and how?" |
| **OpenAEV** | Adversarial exposure validation (evolved from OpenBAS). Turns threat intel into attack simulations and exercises. | "Would our defenses actually stop them?" |
| **OpenCRQ** | Cyber risk quantification (coming soon). Combines business context, assets, threats and tested controls into a risk figure. | "What is this risk worth in money?" |
| **XTM One** | Agentic AI layer that connects OpenCTI and OpenAEV into one workflow. Bring-your-own LLM, can run on-premises. | "How do we do all this without more headcount?" |

**How it maps to CTEM** (Gartner's five stages, my read):

- **Scoping and discovery:** OpenCTI (which threats matter to this business)
- **Prioritization:** OpenCTI plus OpenCRQ (which exposures matter most, in business terms)
- **Validation:** OpenAEV (do our controls hold up)
- **Mobilization:** XTM One (automating the handoffs between the steps)

---

## Customer journey and success plan

| Phase | Timing | What I'd do | Success signal |
|---|---|---|---|
| **Kickoff** | Week 0–1 | Map stakeholders (CISO or exec sponsor, CTI lead, SOC manager, platform owner). Agree 2–3 business objectives and written success criteria. Confirm SaaS vs self-hosted. | Signed-off success plan with a named exec sponsor |
| **Onboarding** | Weeks 1–4 | Work with the Platform Architect on sizing and deployment. Connect the first feeds (ATT&CK, CISA KEV, their existing sources). Set up users, roles and TLP markings. Get one real workflow live. | First useful intel in the platform within 30 days |
| **Adoption** | Months 2–3 | Train analysts, build leadership dashboards, connect downstream tools (SIEM, EDR, ticketing). Introduce automation playbooks. | Weekly active analysts growing; at least one downstream integration |
| **Value and growth** | Quarterly | Run QBRs, document outcomes, spot expansion signals. | Exec sponsor attends QBRs; value documented in their terms |
| **Renewal** | 90 days out | Build the business case from the documented outcomes, de-risk early. | Renewal with no surprises, ideally with expansion |

### Expansion signals

- Heavy OpenCTI use, and the board asks "are we protected against X?" → **OpenAEV**
- The CISO needs to justify budget in money terms → **OpenCRQ**
- Analysts are the bottleneck, too much manual enrichment and reporting → **XTM One**
- More teams asking for access (SOC, vulnerability management, risk) → seat and scope expansion

---

## Account health score

| Signal | Why it matters | Red flag |
|---|---|---|
| Connector health and data freshness | No fresh data means no value | Connectors erroring or stale for over a week |
| Weekly active analysts | Shows real daily use | Drop of 30%+ month over month |
| Content created (reports, investigations, cases) | Shows the platform is part of their workflow | Flat or declining after onboarding |
| Downstream integrations | Ties intel to action (SOC, vuln management) | None live after 60 days |
| Exec engagement | Renewals are decided above the analysts | Sponsor skipped the last QBR, or left the company |
| Support ticket trend | Spots friction early | The same issue keeps coming back |
| Version currency (self-hosted) | Old versions mean missed value and more bugs | Several major releases behind |

---

## QBR structure

1. **Goals recap:** what we agreed to achieve and where we stand
2. **Their threat landscape:** what changed this quarter for their sector and region (active intrusion sets, newly exploited CVEs)
3. **Adoption:** usage, connectors, integrations, health score trend
4. **Value delivered, in business terms:** analyst hours saved, time from new intel to detection, exposures validated and fixed
5. **What's new:** roadmap items relevant to their goals
6. **Next quarter:** success plan updates, owners and dates

### Example value calculation (illustrative)

> 4 analysts × 6 hours/week saved on manual feed collection and enrichment × €60/hour loaded cost × 48 weeks = **~€69,000/year** in analyst time.

The assumptions are made up for illustration. In a real account, every number comes from the customer and gets agreed with them, so the business case holds up when their CFO looks at it.

---

## Common risks and how I'd handle them

- **Self-hosted stack sized too small:** the platform runs slowly and the customer blames the product. → Sizing review with the Platform Architect before go-live.
- **"Data swamp":** too many feeds, nothing prioritized. → Start from their priority intelligence requirements and add feeds that serve them.
- **Single champion:** the account is at risk if they leave. → Build relationships with several people from kickoff (sponsor, CTI lead, SOC).
- **Seen as the CTI team's tool:** hard to justify at renewal. → Tie usage to SOC and vulnerability management outcomes early.
- **"Why pay when it's open source?":** → Make the value of enterprise features, support and expertise visible in every QBR.

---

## Lab notes

I ran the official [OpenCTI Docker stack](https://github.com/OpenCTI-Platform/docker) locally on Windows (Docker Desktop + WSL2 Ubuntu): OpenCTI and XTM One, both Community Edition, with the default MITRE ATT&CK connector plus the CISA Known Exploited Vulnerabilities connector I added. The setup script and compose override are in this repo ([`setup-opencti.sh`](setup-opencti.sh), [`docker-compose.override.yml`](docker-compose.override.yml)).

### What came in during the first hour

- 17 integrations deployed, 3 workers, ~487K documents processed
- 189 intrusion sets, 746 malware, 1.31K attack patterns, 1.79K vulnerabilities

![Home dashboard](screenshots/01-home.png)
![Integrations](screenshots/02-integrations.png)

I looked up APT28 and Sandworm Team first. Both are attributed to Russia's GRU and both have targeted Georgia, where I'm based, so that's the threat landscape I'd care about as a customer here.

![APT28 search](screenshots/05-apt28-search.png)

More: [attack patterns](screenshots/03-attack-patterns.png) · [intrusion sets](screenshots/04-intrusion-sets.png) · [vulnerabilities](screenshots/06-vulnerabilities.png) · [XTM One](screenshots/07-xtm-one.png)

### Onboarding friction log: what a new customer would trip over

1. **Prerequisites before the platform even boots.** On Windows: WSL2, the Docker Desktop WSL integration toggle, docker group permissions, and raising `vm.max_map_count` for Elasticsearch through `.wslconfig`. Each one is a hard stop with an error message that doesn't point at the fix.
   → *CSM move:* send a pre-flight checklist before kickoff, and for self-hosted customers, hold a short prerequisites and sizing call with the Platform Architect.

2. **A connector failed quietly.** My setup script added the CISA connector's ID to `.env`, but the sample file has no trailing newline, so the value got stuck onto the previous line. The stack came up "fine", but the CISA connector sat in a restart loop. I caught it from the compose warning (`CONNECTOR_CISA_ID variable is not set`) and the `Restarting` status in `docker compose ps`.
   → *Lesson:* "the platform is up" doesn't mean "the data is flowing". Check connector health first in every onboarding.

3. **"9 integrations are degraded: User is not a service account."** The default stack runs every connector on the admin token. Everything works, but every imported object shows `admin` as its creator, so you can't tell which source created what.
   → *Production:* give each connector its own service account. It's much easier to set up on day one than to untangle later, so it belongs on the onboarding checklist.

4. **Data isn't value yet.** MITRE fills in the "who and how" (actors, techniques, malware), but the home dashboard still shows **0 reports, 0 indicators** and "Most targeted victims: No data found." Targeted countries and sectors are blank on the intrusion set cards, and the KEV CVEs have no CVSS severity.
   → *What this means for a customer:* time to first value depends on which feeds they connect. They need an indicator feed (an ISAC or OTX) for detections, an enrichment source for severity, and their own reports. That's the week-2 onboarding conversation, driven by their PIRs (the platform has a dedicated PIR section for this).

### Community vs Enterprise: what I saw

- **OpenCTI CE:** the core platform, connectors, integrations view and dashboards all work. The "Ask Ariane" AI assistant is marked EE.
- **XTM One CE:** connects to OpenCTI out of the box. Operations and Files are open. Chat, Value, Presentations and all of Agent Studio (Knowledge, Prompts, Templates, Skills) are locked behind Enterprise.
  → *CSM angle:* judging by the names, Value and Presentations sit right where QBR and ROI work happens. For a customer already building value reports by hand, that's a natural expansion conversation.

---

## Sources

- [OpenCTI documentation](https://docs.opencti.io/latest/)
- [OpenCTI Docker deployment](https://github.com/OpenCTI-Platform/docker)
- [XTM One](https://filigran.io/platform/xtm-one/)
- [OpenCRQ](https://filigran.io/products/opencrq)
- [MITRE ATT&CK](https://attack.mitre.org/)
- [CISA Known Exploited Vulnerabilities](https://www.cisa.gov/known-exploited-vulnerabilities-catalog)
