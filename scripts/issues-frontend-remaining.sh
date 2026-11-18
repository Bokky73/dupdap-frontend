#!/usr/bin/env bash
set -e
REPO="dupdab/dupdap-frontend"

i() {
  gh issue create --repo "$REPO" --title "$1" --body "$2"
  sleep 0.3
}

echo "=== Creating remaining frontend issues ==="

i "testing: no tests for getErrorMessage with all backend error shapes" "\`errors.ts\` handles multiple error shapes but tests may not cover all backend error formats (AxiosError, plain Error, string, unknown).

**Acceptance criteria:**
- [ ] Test for each shape: AxiosError with response.data.message, plain Error, string, null, undefined
- [ ] Test for nested error arrays (NestJS validation errors)
- [ ] 100% branch coverage on getErrorMessage"

i "testing: no accessibility tests for pay page — customer-facing flow must meet WCAG AA" "The pay page tests cover functionality but no accessibility assertions.

**Acceptance criteria:**
- [ ] Run axe-core against pay page rendered state
- [ ] Test: all interactive elements reachable by keyboard
- [ ] Test: status announcements via aria-live regions"

i "testing: no tests for useFocusTrap hook — focus trap behavior untested" "\`useFocusTrap.ts\` has no test file. Focus trap failure breaks accessibility for all modals and drawers.

**Acceptance criteria:**
- [ ] Test: Tab cycles through focusable elements within trap
- [ ] Test: Shift+Tab cycles backward
- [ ] Test: focus returns to trigger on trap release"

i "testing: dashboard nav active state tests do not cover nested route patterns" "Nav active state tests exist but may not cover nested routes (e.g. /dashboard/payments/[id] should activate the Payments nav item).

**Acceptance criteria:**
- [ ] Test: /dashboard/payments/[id] activates Payments nav item
- [ ] Test: /dashboard/settlements/[id] activates Settlements nav item
- [ ] Test: exact match vs prefix match distinction"

i "testing: no tests for middleware — unauthenticated redirect behavior not covered" "\`src/middleware.ts\` redirects unauthenticated users to /auth/login but has no test coverage.

**Acceptance criteria:**
- [ ] Test: request to /dashboard without token redirects to /auth/login
- [ ] Test: request to /pay/[id] without token is allowed through
- [ ] Test: authenticated request to /auth/login redirects to /dashboard"

i "testing: no tests for auth-redirect utility edge cases" "\`auth-redirect.ts\` has a test file but verify all redirect cases are covered.

**Acceptance criteria:**
- [ ] Test: authenticated user visiting /auth/login is redirected to /dashboard
- [ ] Test: unauthenticated user visiting /dashboard is redirected to /auth/login
- [ ] Test: ?next= param is preserved and validated to same origin"

i "testing: no tests for env validation — invalid env vars silently accepted in test environment" "\`env.ts\` validates required env vars but tests may not cover all invalid inputs.

**Acceptance criteria:**
- [ ] Test: missing NEXT_PUBLIC_API_URL in production throws
- [ ] Test: invalid URL format is rejected
- [ ] Test: valid config passes without error"

i "dx: no CONTRIBUTING.md — new contributors have no onboarding guide" "No contribution guide exists for the frontend repo.

**Acceptance criteria:**
- [ ] CONTRIBUTING.md: branch naming, PR process, test requirements, design conventions
- [ ] PR template in .github/pull_request_template.md"

i "dx: TypeScript strict mode not enabled — potential runtime errors hidden by missing null checks" "\`tsconfig.json\` may not have \`strict: true\`, leaving \`strictNullChecks\` and \`noImplicitAny\` disabled.

**Acceptance criteria:**
- [ ] Enable \`strict: true\` in tsconfig.json
- [ ] Fix all resulting type errors
- [ ] CI type-check step must pass"

i "dx: no husky pre-commit hook — lint and type-check not enforced before commit" "Developers can commit code that fails lint or type-check. CI is the only gate, causing slow feedback loops.

**Acceptance criteria:**
- [ ] husky + lint-staged: run \`next lint\` on staged files pre-commit
- [ ] Run \`tsc --noEmit\` on pre-commit
- [ ] Setup documented in CONTRIBUTING.md"

i "dx: no .github/CODEOWNERS file — PRs have no automatic reviewer assignment" "No CODEOWNERS file exists. PRs require manual reviewer assignment every time.

**Acceptance criteria:**
- [ ] .github/CODEOWNERS assigning reviewers for src/app, src/lib, src/components
- [ ] At least one owner must review before merge"

i "dx: Tailwind brand colors not documented — new developers use arbitrary hex values" "The custom brand color scale in \`tailwind.config.ts\` is not documented. Developers may use arbitrary hex values instead of the design system colors.

**Acceptance criteria:**
- [ ] Document all brand colors in a design-system.md or Storybook
- [ ] README link to color documentation"

i "dx: no Storybook or component library — UI components cannot be developed in isolation" "No Storybook is set up. Developers cannot view or test components in isolation without running the full app.

**Acceptance criteria:**
- [ ] Set up Storybook with Next.js integration
- [ ] Stories for: Modal, FormField, Skeleton, ConfirmDialog, StatusBadge
- [ ] CI step to build Storybook and check for errors"

i "dx: vitest config has no coverage threshold — test coverage can silently drop to 0%" "No coverage threshold is set in \`vitest.config.ts\`.

**Acceptance criteria:**
- [ ] Set coverage thresholds: lines 70%, functions 70%, branches 60%
- [ ] CI fails if coverage drops below threshold
- [ ] Coverage badge in README"

i "dx: no CHANGELOG.md — breaking UI changes undocumented" "No changelog exists. API or behavior changes are undiscoverable without reading git history.

**Acceptance criteria:**
- [ ] CHANGELOG.md with entries for all breaking changes
- [ ] Conventional commits enforced via commitlint"

i "dx: ESLint config missing @typescript-eslint/recommended-type-checked rules" "The ESLint config may not include TypeScript-aware linting rules that catch type errors at lint time.

**Acceptance criteria:**
- [ ] Enable \`@typescript-eslint/recommended-type-checked\`
- [ ] Fix all new violations
- [ ] CI lint step must pass"

i "dx: no docker-compose for full-stack local dev — backend must be run separately" "Developers need to run the backend separately. No Docker Compose ties the frontend, backend, and their dependencies together.

**Acceptance criteria:**
- [ ] docker-compose.dev.yml that starts frontend, backend, Postgres, and Redis
- [ ] README updated with single-command full-stack setup"

i "security: Content-Security-Policy missing connect-src directive for API domain" "The CSP header may not include a \`connect-src\` directive covering the backend API domain. API calls would be blocked in strict CSP environments.

**Acceptance criteria:**
- [ ] Add \`connect-src 'self' \${NEXT_PUBLIC_API_URL}\` to CSP
- [ ] Add wss:// entry for future WebSocket connection
- [ ] E2E test with CSP reporting enabled"

i "security: X-Frame-Options set to DENY — payment embed use case blocked" "If merchants want to embed the pay page in an iframe on their storefront, the DENY policy blocks it.

**Acceptance criteria:**
- [ ] Change to SAMEORIGIN or add configurable ALLOW-FROM
- [ ] Document the tradeoff between security and embed use case
- [ ] Add \`frame-ancestors\` CSP directive"

i "security: Zustand store not cleared on login from a different account — stale state visible" "If merchant A logs out and merchant B logs in on the same browser, old store state may persist before the new user's data loads.

**Acceptance criteria:**
- [ ] Clear all non-auth Zustand stores on logout
- [ ] Clear all SWR/React Query caches on logout
- [ ] Unit test: login after logout shows no previous user's data"

i "security: no rate limit on frontend login form — brute-force via UI is unrestricted" "The frontend login form has no debounce or submission rate limiting. A script can hammer the backend via the UI.

**Acceptance criteria:**
- [ ] Disable submit button for 2s after each failed attempt
- [ ] Show lockout message when backend returns lockout error
- [ ] Unit test for lockout error display"

i "security: merchant profile object stored in localStorage — readable by extensions" "Zustand persist stores the merchant profile (business name, country, role) in plaintext localStorage.

**Acceptance criteria:**
- [ ] Store only the token in localStorage (minimum necessary)
- [ ] Remove merchant profile from persisted state; fetch on-demand
- [ ] Or encrypt persisted data with a session-derived key"

i "i18n: all user-facing strings hardcoded in English — no i18n framework in place" "All user-facing text is hardcoded in English. The platform serves international merchants but provides no localization.

**Acceptance criteria:**
- [ ] Set up next-intl or react-i18next
- [ ] Extract all hardcoded strings to translation files
- [ ] Support at least: English, French, Portuguese"

i "i18n: dates displayed in US format (MM/DD/YYYY) — confusing for non-US merchants" "Date formatting likely uses JavaScript defaults which may output US-style dates.

**Acceptance criteria:**
- [ ] Use \`Intl.DateTimeFormat\` with merchant's locale
- [ ] Format: DD/MM/YYYY for UK/NG, YYYY-MM-DD for ISO contexts
- [ ] Unit test for each locale"

i "i18n: currency amounts not formatted with locale-appropriate separators" "Amount formatting uses hardcoded decimal point. Some locales use comma as decimal separator.

**Acceptance criteria:**
- [ ] Use \`Intl.NumberFormat\` for all currency displays
- [ ] Respect merchant's browser locale for formatting
- [ ] Unit test: 1234567.89 formats correctly for en-US, en-GB, fr-FR"

i "i18n: payment status labels shown as raw enum values — PENDING, CONFIRMED displayed as-is" "Payment status values from the backend are displayed directly without mapping to human-readable labels.

**Acceptance criteria:**
- [ ] Map all status enum values to display labels (e.g. CONFIRMED → 'Confirmed')
- [ ] Labels should be translatable in i18n framework
- [ ] Unit test for each status mapping"

i "ux: payment creation form resets on API error — merchant loses all entered data" "If payment creation fails, the form resets to empty. The merchant must re-enter all fields.

**Acceptance criteria:**
- [ ] Preserve form values on API error
- [ ] Show specific error message from API
- [ ] Unit test: form values preserved after failed submit"

i "ux: no confirm step before payment creation — accidental submissions create real payments" "The payment creation form submits immediately on clicking Create Payment with no confirmation step.

**Acceptance criteria:**
- [ ] Show confirmation summary: 'Create a payment for \$25.00?' with Confirm/Cancel
- [ ] Use ConfirmDialog component
- [ ] Unit test for confirmation flow"

i "ux: settlement list does not show linked payment count per settlement row" "The settlement list shows gross/net amounts but not how many payments were batched into each settlement.

**Acceptance criteria:**
- [ ] Show payment count per settlement row
- [ ] Clicking the count opens a panel listing the linked payments"

i "ux: no onboarding flow for new merchants — empty dashboard with no guidance" "New merchants land on an empty dashboard with no onboarding steps, checklist, or tooltip tour.

**Acceptance criteria:**
- [ ] 5-step onboarding checklist: complete profile, add bank account, create test payment, set up webhook, go live
- [ ] Checklist persists in localStorage until all steps done
- [ ] Each step links to the relevant settings or action"

i "ux: webhook creation form has no event subscription descriptions or payload preview" "The webhook creation form lists event names with no description or payload preview.

**Acceptance criteria:**
- [ ] Tooltip or expandable section per event name with description and sample payload
- [ ] Link to webhook documentation"

i "ux: no breadcrumb navigation on nested dashboard pages" "On nested pages like /dashboard/payments/[id] there is no breadcrumb showing the navigation path.

**Acceptance criteria:**
- [ ] Breadcrumb component: Dashboard > Payments > PAY-123
- [ ] Dynamic breadcrumbs based on route
- [ ] Accessible: nav landmark with aria-label='Breadcrumb'"

i "ux: amount input does not format number on blur — 25 stays as 25 instead of 25.00" "The payment amount input shows an unformatted number. Users expect currency inputs to show two decimal places.

**Acceptance criteria:**
- [ ] On blur, format to 2 decimal places (25 → 25.00)
- [ ] Show currency symbol aligned to the left of the input
- [ ] Unit test for format-on-blur behavior"

i "ux: webhook list shows full URLs — long URLs break layout on mobile" "Long webhook URLs overflow their table cell on mobile viewports, breaking the table layout.

**Acceptance criteria:**
- [ ] Truncate URLs at 50 characters with ellipsis
- [ ] Show full URL on hover (tooltip)
- [ ] Copy-to-clipboard on click"

i "ux: no visual indicator for sandbox mode — merchants may not know they are in test mode" "If a merchant is in sandbox mode, the dashboard looks identical to production mode.

**Acceptance criteria:**
- [ ] Show a 'Sandbox Mode' banner at the top of all dashboard pages in sandbox mode
- [ ] Banner color: yellow/amber
- [ ] 'Switch to production' CTA linking to settings"

i "ux: payment QR code on dashboard not downloadable — merchants cannot print or share it" "The QR code shown after payment creation cannot be downloaded as an image.

**Acceptance criteria:**
- [ ] 'Download QR' button saves PNG to disk
- [ ] 'Copy link' button copies the payment page URL"

i "ux: no print styles — payment receipts look broken when printed" "No CSS print media query styles exist. Printing a receipt renders navigation, sidebars, and buttons on paper.

**Acceptance criteria:**
- [ ] Print stylesheet hides navigation, sidebar, and action buttons
- [ ] Print receipt shows only: merchant name, payment details, amount, status"

i "ux: settlement approval status not explained to merchant — PENDING_APPROVAL shown with no context" "When a settlement requires admin approval, the merchant sees PENDING_APPROVAL with no explanation.

**Acceptance criteria:**
- [ ] Display 'Awaiting approval — large settlements are manually reviewed within 24h'
- [ ] Show estimated approval time
- [ ] Email merchant when settlement is approved or rejected"

i "ux: payment list defaults to showing all statuses — pending+confirmed is more actionable" "The default payment list view shows all statuses mixed together. For daily operations, merchants primarily care about pending and confirmed payments.

**Acceptance criteria:**
- [ ] Default filter: PENDING + CONFIRMED
- [ ] 'All payments' option to remove filter
- [ ] Persist selected filter in URL"

i "ux: no mobile-optimized payment creation flow — desktop-only form UX" "The payment creation form is designed for desktop. On mobile, multi-field forms are hard to use.

**Acceptance criteria:**
- [ ] Multi-step form on mobile: amount → description → customer email → review
- [ ] Single-step form on desktop
- [ ] Mobile breakpoint at 768px"

i "ux: dark mode not supported — merchants working at night have no alternative" "The app has no dark mode support.

**Acceptance criteria:**
- [ ] Implement dark mode using Tailwind's \`dark:\` variant
- [ ] Respect \`prefers-color-scheme\` by default
- [ ] Manual toggle in dashboard settings
- [ ] Persist preference in localStorage"

i "dx: no API mock server for local frontend dev without running full backend" "Frontend developers must run the full backend stack locally. No mock server exists for frontend-only development.

**Acceptance criteria:**
- [ ] MSW (Mock Service Worker) setup for local development
- [ ] Mock handlers for all API endpoints with realistic data
- [ ] README documents how to start frontend in mock mode"

i "dx: no visual regression testing — UI changes undetected until manual review" "No visual regression tests exist. UI changes (Tailwind updates, component refactors) can silently break the visual appearance.

**Acceptance criteria:**
- [ ] Integrate Chromatic or Percy for visual regression testing
- [ ] Run on every PR against main branch
- [ ] Approve visual changes explicitly before merge"

i "dx: package.json missing engines field — wrong Node.js version used silently" "No \`engines\` field in package.json. Developers running Node 16 instead of 18 get no warning.

**Acceptance criteria:**
- [ ] Add \`'engines': { 'node': '>=18' }\` to package.json
- [ ] Verify .nvmrc matches engines field
- [ ] CI uses exact Node version from .nvmrc"

i "dx: no verify script in package.json — type-check, lint, and tests require 3 separate commands" "Developers run type-check, lint, and tests separately. A single verify command would speed up pre-PR checks.

**Acceptance criteria:**
- [ ] Add \`'verify': 'npm run type-check && npm run lint && npm test'\` to package.json
- [ ] CI uses \`npm run verify\` as the single check command
- [ ] Document in README and CONTRIBUTING.md"

echo ""
echo "=== Frontend remaining issues done ==="
