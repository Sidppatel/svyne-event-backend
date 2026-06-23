# Frontend & Mobile Integration

How clients call this backend. Transport is **gRPC-Web** (browser) / **gRPC** (native mobile, Next.js server). Auth is **JWT bearer** — no API keys (a browser/mobile client cannot hold a secret safely).

Backend prerequisites already in place:
- gRPC-Web enabled (`UseGrpcWeb`, [Program.cs](../src/Api/Program.cs)).
- CORS wired from `CORS_ORIGINS`, exposing `grpc-status` / `grpc-message` / `grpc-status-details-bin` ([Program.cs](../src/Api/Program.cs)). Set `CORS_ORIGINS` to your frontend origins (comma-separated).
- JWT validation + per-request tenant/RLS context ([TenantResolutionMiddleware](../src/Api/Middleware/TenantResolutionMiddleware.cs)).

Contracts: [`protos/`](../protos). Use [Connect](https://connectrpc.com) — its web client speaks the gRPC-Web this server serves.

---

## 1. Generate typed clients (buf + Connect-ES)

In the **frontend repo**, point buf at these `.proto` files (git submodule, copy, or a Buf registry).

`buf.yaml`
```yaml
version: v2
modules:
  - path: protos
```

`buf.gen.yaml`
```yaml
version: v2
plugins:
  - remote: buf.build/bufbuild/es
    out: src/gen
  - remote: buf.build/connectrpc/query-es   # optional TanStack Query bindings
    out: src/gen
```

```bash
npm i @connectrpc/connect @connectrpc/connect-web @bufbuild/protobuf
npx buf generate
```

---

## 2. Transport + auth interceptor (React, browser)

```ts
// src/api/client.ts
import { createGrpcWebTransport } from "@connectrpc/connect-web";
import { createClient, type Interceptor } from "@connectrpc/connect";
import { AuthService } from "../gen/auth_pb";

let accessToken: string | null = null;
export const setAccessToken = (t: string | null) => { accessToken = t; };

const auth: Interceptor = (next) => async (req) => {
  if (accessToken) req.header.set("Authorization", `Bearer ${accessToken}`);
  return next(req);
};

const transport = createGrpcWebTransport({
  baseUrl: import.meta.env.VITE_API_URL, // https://api.your-domain.com
  interceptors: [auth],
});

export const authClient = createClient(AuthService, transport);
```

Login flow:
```ts
const res = await authClient.login({ email, password, tenantSlug });
setAccessToken(res.accessToken);
```
Every subsequent call on any service client carries the token → server resolves user + tenant → RLS isolates data.

On `Code.Unauthenticated`, call `authClient.refreshToken({ refreshToken })`, store the new token, retry.

> Token storage: prefer in-memory + a refresh strategy over `localStorage` for sensitive apps. See backend follow-up below.

---

## 3. Next.js

- **Client components** → the gRPC-Web transport above.
- **Server components / route handlers / server actions** → no browser limit; use full gRPC:
  ```ts
  import { createGrpcTransport } from "@connectrpc/connect-node";
  const transport = createGrpcTransport({ baseUrl: process.env.API_URL });
  ```
  Forward the user's JWT from cookies/headers into the request metadata.

---

## 4. Mobile (later)

Native iOS / Android / React Native use **full gRPC** against the same protos — no gRPC-Web, no CORS, no API keys:
- iOS: **Connect-Swift** or `grpc-swift`.
- Android: **Connect-Kotlin** or `grpc-kotlin`.
- Same `Authorization: Bearer <jwt>` metadata header.

---

## Verify end-to-end

1. Set `CORS_ORIGINS=http://localhost:5173` (your dev origin), run the API.
2. From the frontend, call `AuthService.Login` → expect token, no CORS error in console, response `grpc-status: 0`.
3. Call an authed RPC (e.g. `EventService.ListEvents`) with the token → returns only the user's tenant data (RLS).
4. Request from an origin not in `CORS_ORIGINS` → blocked. Missing/invalid token → `Unauthenticated`.

---

## Backend follow-up (not blocking)

`AuthResponse.refresh_token` currently equals the access token ([AuthServiceImpl `BuildAuth`](../src/Api/Services/AuthServiceImpl.cs)). For true short-lived access + long-lived refresh, issue two tokens with different lifetimes in `JwtTokenService` / `BuildAuth`. Until then, treat refresh as a same-lifetime re-issue.
