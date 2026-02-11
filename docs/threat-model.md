# Cora threat model (v1.0)

## Goals
- Private messaging for direct messages and invite-only groups.
- No public room directory and no federation.
- Minimize metadata exposure.

## Assumptions
- Homeserver owner controls Matrix Synapse and Postgres.
- `cora-api` maps email ↔ friend code and stores account profile metadata.
- Clients support Matrix encryption defaults.

## Main risks
1. **Server compromise**
   - Risk: attacker reads account table / friendship metadata.
   - Mitigation: hardened host, backups encryption, rotate credentials.
2. **Credential theft**
   - Risk: attacker logs in as a user.
   - Mitigation: strong passwords, rate limiting (future), optional MFA (future).
3. **Metadata leakage**
   - Risk: server sees who talks to whom and when.
   - Mitigation: avoid public directory/federation, keep logs minimal.
4. **Client compromise**
   - Risk: plaintext visible on compromised endpoint.
   - Mitigation: OS updates, lock screen, secure storage for session keys.

## What the server can see
- **Can see (metadata):** email address, friend code, Matrix IDs, room membership, timestamps, IP/device-level connection data.
- **Cannot read encrypted content (when E2EE is active):** DM/group message bodies and attachments encrypted end-to-end.

## Residual risk
- E2EE does not hide contact graph and timing metadata.
- Safety depends on endpoint security and operational hygiene.
