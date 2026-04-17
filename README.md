# Swift-SCA-Demo

A demo iOS app showing how Strong Customer Authentication (SCA) can be integrated in Swift — covering the flow from biometric verification to OTP fallback, session monitoring, and a debug control panel for testing edge cases.

If you want to understand the regulation before diving into code, start with the [blog post](https://dev.to/lukagujejiani/strong-customer-authentication-sca-in-swift-44jo).

---

## What is SCA?

Strong Customer Authentication is a multi-factor authentication standard built for securing payments, originating from the EU's PSD2 regulation. The principle behind it applies anywhere sensitive actions need protecting — logging in, viewing private data, transferring money, anything worth guarding really.

SCA requires at least two of the following three factors:

- **Knowledge** — something the user knows (PIN, password)
- **Possession** — something the user has (device, OTP)
- **Inherence** — something the user is (Face ID, fingerprint)

---

## What This Demo Covers

- **SCA authentication flow** — biometric primary auth with OTP fallback
- **OTP resend with cooldown** — rate-limited resend logic
- **Session monitoring** — token validity tracking via `SessionMonitor`
- **Mock server & gateway** — `MockSCAServer` and `MockSCAGateway` simulate a real backend without any network dependency
- **Debug control panel** — force different auth states and edge cases at runtime

---

## Requirements

- iOS 16+
- Xcode 15+
- Swift 5.9+

---

## Getting Started

```bash
git clone https://github.com/GujMeister/Swift-SCA-Demo.git
cd Swift-SCA-Demo
open Swift-SCA-Demo.xcodeproj
```

No external dependencies. Build and run on a simulator or device.

---

## Related

**SCACore** — the standalone SCA framework extracted from this project, built as a Swift Package for drop-in integration.
→ [github.com/GujMeister/SCACore](https://github.com/GujMeister/SCACore)

---
