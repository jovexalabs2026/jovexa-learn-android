# Security Policy

## Supported versions

Only the latest released version of Jovexa Learn for Android receives security updates.

## Reporting a vulnerability

Please report security issues privately to **support@jovexalabs.com**. Do not open a public GitHub issue for security problems.

Include:

- A description of the issue and its impact
- Steps to reproduce
- The app version and Android version tested

You will receive an acknowledgment as soon as possible, and a fix will be prioritized based on severity.

## Scope notes

- The app stores learning progress locally with shared_preferences and collects no personal data.
- The Code Lab WebView only renders code the user types on the device. All outbound navigation from the WebView is blocked, and JavaScript runs without bridges to app code.
- The only Android permission requested is INTERNET.
- No API keys, keystores, or production ad identifiers exist in this repository. If you find one, treat it as a vulnerability and report it.
