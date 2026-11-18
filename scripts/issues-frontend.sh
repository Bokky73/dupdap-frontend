#!/usr/bin/env bash
set -e
REPO="dupdab/dupdap-frontend"

i() {
  gh issue create --repo "$REPO" --title "$1" --body "$2"
  sleep 0.3
}

echo "=== Creating 125 frontend issues ==="

i "auth: access token stored in localStorage — readable by any XSS payload" "The JWT is persisted in localStorage via Zustand persist. Any XSS vector on the domain can read it synchronously.

**Acceptance criteria:**
- [ ] Move to httpOnly SameSite=Strict cookie issued by the backend
- [ ] Remove token from Zustand persist store
- [ ] Frontend never handles the raw JWT string"

i "auth: Zustand auth store persists token under a fixed key — multiple tabs share stale token" "All tabs read from the same localStorage key. A logout in one tab does not propagate to other tabs until they reload.

**Acceptance criteria:**
- [ ] Listen to localStorage storageEvent across tabs
- [ ] Logout in one tab triggers logout in all open tabs
- [ ] Unit test for cross-tab logout"

i "auth: 401 response interceptor redirects to /auth/login — loses the originally requested URL" "When a 401 occurs the interceptor calls \`logout()\` and redirects to /auth/login with no \`?next=\` param, so the user lands on the dashboard root after re-login instead of their original page.

**Acceptance criteria:**
- [ ] Encode the current path as \`?next=\` on the login redirect
- [ ] After login, redirect to \`next\` param (validated to same origin)
- [ ] Unit test for redirect preservation"

i "auth: login form has no autocomplete attributes — password managers cannot autofill" "Login and register forms are missing \`autocomplete\` attributes on email and password fields.

**Acceptance criteria:**
- [ ] \`autocomplete='email'\` on email fields
- [ ] \`autocomplete='current-password'\` on login password
- [ ] \`autocomplete='new-password'\` on register password
- [ ] \`autocomplete='off'\` on TOTP code field"

i "auth: register form does not confirm password — typo creates inaccessible account" "Registration has only one password field. A typo locks the merchant out of their account immediately.

**Acceptance criteria:**
- [ ] Add confirm password field
- [ ] Validate both fields match before submission
- [ ] Show inline error if they differ"

i "auth: no session expiry warning before token expires — users lose unsaved work" "The 7-day JWT expires with no warning. Merchants filling long forms lose their work when the session expires mid-edit.

**Acceptance criteria:**
- [ ] Show a banner 5 minutes before token expiry
- [ ] Offer one-click session extension (calls refresh endpoint)
- [ ] Auto-logout on expiry with toast notification"

i "auth: forgot-password page has no test coverage" "No test file exists for the forgot-password page or its form submission logic.

**Acceptance criteria:**
- [ ] Test: renders form
- [ ] Test: submits email and shows success message
- [ ] Test: shows error on API failure
- [ ] Test: validates email format before submit"

i "auth: reset-password page has no test coverage" "No test file exists for the reset-password page or its token validation/form logic.

**Acceptance criteria:**
- [ ] Test: renders with valid token
- [ ] Test: shows error for expired/invalid token
- [ ] Test: submits new password and redirects to login
- [ ] Test: validates password confirmation match"

i "auth: no CSRF protection on API requests — SameSite cookie migration needs CSRF token" "When the JWT moves to a cookie, the API requests need a CSRF token or rely on SameSite=Strict to prevent cross-site request forgery.

**Acceptance criteria:**
- [ ] Document CSRF strategy in README
- [ ] Implement Double Submit Cookie or backend-issued CSRF token
- [ ] All state-mutating requests include CSRF header"

i "auth: logout does not call backend /auth/logout — token not blacklisted server-side" "\`logout()\` in the Zustand store clears local state but never calls the backend logout endpoint, so the JWT remains valid on the server until expiry.

**Acceptance criteria:**
- [ ] Call \`POST /auth/logout\` before clearing local state
- [ ] Handle network failure gracefully (still clear local state)
- [ ] Unit test asserting API call is made"

i "pay-page: payment status polling has no exponential backoff — hammers backend on slow confirmations" "The customer pay page polls \`GET /payments/:id/status\` on a fixed interval with no backoff. For payments that take minutes to confirm this creates unnecessary backend load.

**Acceptance criteria:**
- [ ] Start polling every 3s, back off to 10s after 10 attempts, then 30s
- [ ] Stop polling after 15 minutes and show timeout state
- [ ] Resume on tab focus if polling was paused"

i "pay-page: no timeout state shown to customer — payment page spins indefinitely" "If a payment is never confirmed the pay page polls forever. The customer has no indication that something may be wrong.

**Acceptance criteria:**
- [ ] Show 'Payment is taking longer than expected' after 5 minutes
- [ ] Show 'Payment expired' state once backend returns EXPIRED status
- [ ] Provide 'Start a new payment' CTA"

i "pay-page: Stellar URI QR code not validated before render — malformed URI crashes qrcode.react" "The QR code is rendered directly from the backend \`stellarUri\` field with no client-side validation. A malformed URI could throw in qrcode.react.

**Acceptance criteria:**
- [ ] Validate URI starts with \`web+stellar:pay?\` before passing to QR renderer
- [ ] Show error state if URI is invalid
- [ ] Unit test with malformed URI"

i "pay-page: crypto amount not refreshed when XLM rate changes during long pending state" "The XLM amount shown to the customer is calculated at payment creation. If the rate moves significantly during the payment window, the displayed amount becomes stale.

**Acceptance criteria:**
- [ ] Show a 'Rate updated — please review new amount' banner if rate changed > 2%
- [ ] Provide a refresh button that fetches current payment details
- [ ] Unit test for stale rate detection"

i "pay-page: no deep link to wallet app on mobile — customer must copy address manually" "On mobile, the Stellar URI is shown as a QR code but there is no tap-to-open deep link for Stellar wallet apps.

**Acceptance criteria:**
- [ ] Render \`<a href={stellarUri}>\` alongside the QR code on mobile viewports
- [ ] Label: 'Open in Wallet'
- [ ] Falls back gracefully if no wallet app installed"

i "pay-page: payment receipt page not implemented — receipt link returns 404 after settlement" "The pay page flow references a receipt view after settlement but no receipt route exists.

**Acceptance criteria:**
- [ ] \`/pay/[paymentId]/receipt\` page
- [ ] Shows: amount paid, date, merchant name, transaction hash
- [ ] Printable layout (CSS print media query)
- [ ] Link to receipt in settlement email"

i "pay-page: no accessibility label on QR code image — screen readers get no information" "The QR code rendered by qrcode.react has no alt text or aria-label. Screen reader users cannot determine what the QR code represents.

**Acceptance criteria:**
- [ ] Add \`aria-label='Stellar payment QR code — scan with your wallet app'\` to QR container
- [ ] Add a text alternative showing the deposit address and amount
- [ ] Accessibility test using axe-core"

i "pay-page: copy-to-clipboard for deposit address has no success feedback" "The deposit address copy button has no visual or accessible confirmation that the copy succeeded.

**Acceptance criteria:**
- [ ] Show 'Copied!' text for 2 seconds after successful copy
- [ ] Use aria-live region to announce copy to screen readers
- [ ] Handle clipboard API unavailability gracefully"

i "pay-page: no error boundary on pay page — any JS error shows blank white screen to customer" "The customer pay page has no React error boundary. An uncaught error during payment flow shows a blank white screen.

**Acceptance criteria:**
- [ ] Wrap pay page in an ErrorBoundary component
- [ ] Show a user-friendly error message with 'Try again' CTA
- [ ] Report error to Sentry with payment ID context"

i "pay-page: payment amount displayed without currency symbol — ambiguous for international customers" "The payment amount is shown as a bare number (e.g. '25.00') without a currency symbol or code, which is ambiguous.

**Acceptance criteria:**
- [ ] Display as 'USD 25.00' or '\$25.00 USD'
- [ ] Also show XLM equivalent: '≈ 125.000000 XLM'
- [ ] Use Intl.NumberFormat for locale-aware formatting"

i "dashboard: StatusPieChart and VolumeBarChart implemented but never rendered anywhere" "Both chart components are fully built but not used on any dashboard page, making them dead code.

**Acceptance criteria:**
- [ ] Render StatusPieChart on the payments overview page
- [ ] Render VolumeBarChart on the analytics page
- [ ] Add snapshot tests once rendered"

i "dashboard: no empty state on payments list — blank table shown when merchant has no payments" "When a merchant has no payments, the payments list renders an empty table with no message or CTA.

**Acceptance criteria:**
- [ ] Show 'No payments yet' illustration and CTA: 'Create your first payment'
- [ ] Link CTA to payment creation flow
- [ ] Unit test for empty state render"

i "dashboard: no empty state on settlements list" "Same issue as payments — empty settlements table shows no message.

**Acceptance criteria:**
- [ ] Show 'No settlements yet' message
- [ ] Explain what a settlement is and when it appears
- [ ] Unit test for empty state"

i "dashboard: payment detail page not implemented — clicking a payment has no destination" "The payments list has no detail view. Clicking a payment row goes nowhere.

**Acceptance criteria:**
- [ ] \`/dashboard/payments/[id]\` page
- [ ] Shows all payment fields, status timeline, webhooks dispatched
- [ ] Link back to payments list"

i "dashboard: settlement detail page not implemented" "No settlement detail view exists.

**Acceptance criteria:**
- [ ] \`/dashboard/settlements/[id]\` page
- [ ] Shows: gross amount, fee, net amount, fiat currency, status, linked payments
- [ ] Download PDF receipt button"

i "dashboard: analytics page has no date range picker — always shows default range" "The analytics page fetches data for the default date range with no UI to change it.

**Acceptance criteria:**
- [ ] Date range picker with presets: Today, 7 days, 30 days, 90 days, Custom
- [ ] URL-encoded date params so range is shareable
- [ ] Charts re-fetch on range change"

i "dashboard: no loading skeleton on initial page load — layout shifts when data arrives" "Dashboard pages show no loading state before data arrives, causing content to pop in and shift the layout.

**Acceptance criteria:**
- [ ] Skeleton components for: payment list rows, analytics charts, stat cards
- [ ] Skeletons shown during initial fetch
- [ ] No layout shift (CLS) on data arrival"

i "dashboard: mobile nav drawer does not close on route change" "On mobile, navigating to a page via the drawer keeps the drawer open, obscuring content.

**Acceptance criteria:**
- [ ] Close drawer on \`router.push()\` or link click
- [ ] Use Next.js \`usePathname()\` to detect navigation
- [ ] Unit test asserting drawer closes on nav"

i "dashboard: no keyboard shortcut to open/close mobile nav drawer" "The mobile nav drawer can only be opened/closed by mouse click. Keyboard users cannot access it without tabbing through the entire page.

**Acceptance criteria:**
- [ ] \`Escape\` key closes the drawer when open
- [ ] Hamburger button is focusable with keyboard and activates on Enter/Space
- [ ] Focus trapped inside drawer when open (already implemented — verify)"

i "dashboard: webhook management page shows no delivery history per webhook" "The webhook list shows endpoints and events but no delivery history, making it impossible to debug failed webhooks from the dashboard.

**Acceptance criteria:**
- [ ] 'View deliveries' link per webhook opens a delivery log panel
- [ ] Shows: timestamp, event, HTTP status, response time, response body preview
- [ ] Paginated, most recent first"

i "dashboard: settings page — API key displayed in full after generation with no masking" "After generating an API key the full key is shown in the settings page with no masking. If the user leaves the tab open, the key is visible to shoulder surfers.

**Acceptance criteria:**
- [ ] Show full key once immediately after generation with a copy button
- [ ] After copy or after 30 seconds, mask to \`sk_live_****\`
- [ ] Confirm before regenerating existing key (ConfirmDialog component)"

i "dashboard: settings page has no test coverage" "No tests exist for the settings page (profile update, API key management, notification preferences).

**Acceptance criteria:**
- [ ] Test: renders merchant profile fields populated
- [ ] Test: profile update submits and shows success toast
- [ ] Test: API key generation shows key and copy button
- [ ] Test: notification toggle updates prefs"

i "dashboard: payments list has no search or filter — merchants with many payments cannot find specific ones" "The payments list is sorted by date only. Merchants cannot filter by status, search by reference, or filter by amount range.

**Acceptance criteria:**
- [ ] Filter by status (multi-select)
- [ ] Search by payment reference
- [ ] Date range filter
- [ ] URL-encoded filter state so filters are bookmarkable"

i "dashboard: no bulk action on payments list — merchants cannot export multiple payments" "No multi-select or bulk export on the payments list.

**Acceptance criteria:**
- [ ] Checkbox per row + select all
- [ ] 'Export selected' action downloads CSV
- [ ] Bulk action bar appears when rows are selected"

i "dashboard: analytics page shows no comparison to previous period by default" "The analytics dashboard shows current period metrics with no comparison to the previous period, making trends invisible.

**Acceptance criteria:**
- [ ] Show +/- percentage vs previous period on each stat card
- [ ] Toggle 'Compare to previous period' on charts
- [ ] Green/red color coding for positive/negative changes"

i "dashboard: dashboard overview page stats are hardcoded or missing — not fetched from API" "The overview page may show placeholder stats instead of live data fetched from the payments stats endpoint.

**Acceptance criteria:**
- [ ] Fetch from \`GET /payments/stats\` on page load
- [ ] Show: total payments, total volume, conversion rate, pending count
- [ ] Loading skeleton while fetching"

i "dashboard: no real-time updates — merchant must refresh to see new payment confirmations" "The dashboard has no WebSocket or SSE connection. Newly confirmed payments only appear after a manual page refresh.

**Acceptance criteria:**
- [ ] Connect to backend WebSocket on dashboard mount
- [ ] Receive \`payment.confirmed\` events and update list in-place
- [ ] Show toast notification on new confirmation"

i "api: settlementsApi helper not implemented in api.ts — pages call api.get() directly" "\`api.ts\` only implements \`authApi\`, \`paymentsApi\`, and \`adminApi\`. Settlement pages call \`api.get()\` directly, bypassing the grouped helper pattern.

**Acceptance criteria:**
- [ ] Add \`settlementsApi\` with: \`list()\`, \`get(id)\`, \`export()\`
- [ ] Migrate all direct \`api.get('/settlements')\` calls to use \`settlementsApi\`"

i "api: webhooksApi helper not implemented in api.ts" "No \`webhooksApi\` grouped helper exists. Webhook pages use ad-hoc calls.

**Acceptance criteria:**
- [ ] Add \`webhooksApi\` with: \`list()\`, \`create()\`, \`update()\`, \`delete()\`, \`rotateSecret()\`
- [ ] Migrate all webhook API calls"

i "api: merchantsApi helper not implemented in api.ts" "No \`merchantsApi\` grouped helper. Settings and profile pages use direct calls.

**Acceptance criteria:**
- [ ] Add \`merchantsApi\` with: \`getProfile()\`, \`updateProfile()\`, \`generateApiKey()\`, \`getNotificationPrefs()\`, \`updateNotificationPrefs()\`
- [ ] Migrate all merchant API calls"

i "api: analyticsApi helper not implemented in api.ts" "No \`analyticsApi\` grouped helper. Analytics pages use direct calls.

**Acceptance criteria:**
- [ ] Add \`analyticsApi\` with: \`getVolume()\`, \`getRevenue()\`, \`getFunnel()\`, \`getComparison()\`
- [ ] Migrate all analytics API calls"

i "api: no request timeout configured on Axios instance — requests hang indefinitely" "The Axios instance in \`api.ts\` has no \`timeout\` configured. A slow backend response hangs the UI indefinitely.

**Acceptance criteria:**
- [ ] Set \`timeout: 30000\` on the Axios instance
- [ ] Show 'Request timed out' error message on timeout
- [ ] Unit test for timeout error handling"

i "api: error response shape not normalized — different pages handle errors differently" "Some pages use \`error.response.data.message\`, others use \`getErrorMessage(error)\`. Inconsistent error handling leads to raw API errors shown to users.

**Acceptance criteria:**
- [ ] Response interceptor normalizes all errors to \`{ message: string }\`
- [ ] All pages use \`getErrorMessage\` from \`errors.ts\`
- [ ] Unit test for each error shape the backend can return"

i "api: no retry logic for transient network errors — single failure shows error to user" "If a request fails due to a transient network error (502, 503, network timeout), the UI immediately shows an error rather than retrying.

**Acceptance criteria:**
- [ ] Retry up to 2 times on 502, 503, and network timeout errors
- [ ] Exponential backoff: 1s, 3s
- [ ] Do not retry on 400, 401, 403, 404, 422"

i "api: API base URL falls back to localhost in production if env var missing — silent misconfiguration" "\`api.ts\` falls back to \`http://localhost:3000/api/v1\` if \`NEXT_PUBLIC_API_URL\` is unset. In production this silently hits nothing.

**Acceptance criteria:**
- [ ] In production build (\`NODE_ENV=production\`), throw at startup if \`NEXT_PUBLIC_API_URL\` is unset
- [ ] \`env.ts\` validates all required env vars at startup
- [ ] CI fails if env validation throws"

i "api: no request cancellation on component unmount — state updates on unmounted components" "API requests initiated on mount are not cancelled when the component unmounts, causing React state updates on unmounted components and potential memory leaks.

**Acceptance criteria:**
- [ ] Use AbortController in all data-fetching hooks
- [ ] Cancel pending request in useEffect cleanup
- [ ] Unit test asserting no state update after unmount"

i "components: LandingNav has no test coverage" "No tests exist for the LandingNav component.

**Acceptance criteria:**
- [ ] Test: renders logo and nav links
- [ ] Test: mobile menu opens and closes
- [ ] Test: active link highlighted on current route
- [ ] Test: keyboard navigation works"

i "components: landing page has no test coverage" "No tests exist for the main landing page (\`src/app/page.tsx\`).

**Acceptance criteria:**
- [ ] Test: renders hero section with CTA
- [ ] Test: CTA links to /auth/register
- [ ] Test: waitlist link present
- [ ] Snapshot test"

i "components: ConfirmDialog not used for all destructive actions — some use window.confirm" "Some destructive actions (e.g. delete webhook, revoke API key) may still use \`window.confirm\` instead of the shared \`ConfirmDialog\` component.

**Acceptance criteria:**
- [ ] Audit all destructive actions across dashboard pages
- [ ] Replace any \`window.confirm\` with \`ConfirmDialog\`
- [ ] Unit test for each destructive action confirmation flow"

i "components: Modal component does not restore focus to trigger element on close" "When the Modal closes, focus is not returned to the element that opened it. Screen reader and keyboard users lose their position.

**Acceptance criteria:**
- [ ] Store ref to trigger element on open
- [ ] Return focus to trigger element on close
- [ ] Unit test: focus is on trigger after modal closes"

i "components: Skeleton component has no reduced-motion variant" "The Skeleton component uses a pulse animation. Users with \`prefers-reduced-motion\` see the animation even though it may cause discomfort.

**Acceptance criteria:**
- [ ] Use \`@media (prefers-reduced-motion: reduce)\` to disable animation
- [ ] Replace animation with static gray color in reduced-motion mode
- [ ] Unit test checks class applied in reduced-motion context"

i "components: FormField error message not associated with input via aria-describedby" "FormField renders an error message below the input but the input element has no \`aria-describedby\` pointing to the error, so screen readers don't announce it.

**Acceptance criteria:**
- [ ] Add \`id\` to error message element
- [ ] Add \`aria-describedby={errorId}\` to the input when error is present
- [ ] Add \`aria-invalid='true'\` to input when in error state
- [ ] Accessibility unit test"

i "components: no toast for successful payment creation — merchant gets no visual confirmation" "After creating a payment, the merchant is redirected or the form resets with no success feedback.

**Acceptance criteria:**
- [ ] Show success toast: 'Payment created — share the QR code with your customer'
- [ ] Toast includes a link to the payment detail page
- [ ] Unit test asserting toast shown on success"

i "components: no global error boundary at app root — unhandled errors show blank screen" "No React ErrorBoundary wraps the app root. An uncaught error anywhere in the app shows a blank white screen.

**Acceptance criteria:**
- [ ] Add ErrorBoundary at \`src/app/layout.tsx\` root
- [ ] Show a friendly error page with 'Go back to dashboard' link
- [ ] Report caught errors to Sentry"

i "components: status badge colors defined in utils.ts but not all statuses covered" "\`STATUS_COLORS\` in utils.ts may be missing entries for newer statuses like PARTIALLY_REFUNDED, SETTLING, or CANCELLED.

**Acceptance criteria:**
- [ ] All PaymentStatus and SettlementStatus values have a color entry
- [ ] Fallback to DEFAULT_STATUS_COLOR for unknown statuses (already exists — verify all statuses covered)
- [ ] Unit test asserting no status returns default unexpectedly"

i "components: payment creation form has no character limit on description field" "The description input has no \`maxLength\` attribute. Backend enforces a limit but the frontend gives no feedback until after submission.

**Acceptance criteria:**
- [ ] Add \`maxLength={500}\` to description input
- [ ] Show character counter (e.g. '234 / 500')
- [ ] Disable submit when limit exceeded"

i "components: payment amount input accepts non-numeric input — no validation until submit" "The amount input is \`type='text'\` with no real-time validation. Users can type letters and only see the error on submit.

**Acceptance criteria:**
- [ ] Use \`type='number'\` or validate on \`onChange\`
- [ ] Show inline error if non-numeric value entered
- [ ] Enforce min 0.01 and max 1,000,000 with inline feedback"

i "components: no pagination controls on payments list — only 20 items shown with no way to navigate" "The payments list fetches the first page only with no pagination controls rendered.

**Acceptance criteria:**
- [ ] Previous/Next buttons and page indicator
- [ ] URL-encoded page param so page is preserved on refresh
- [ ] Show total count: 'Showing 1–20 of 847 payments'"

i "a11y: dashboard pages not tested with axe-core — accessibility violations undetected" "No automated accessibility tests run against dashboard pages. WCAG violations accumulate silently.

**Acceptance criteria:**
- [ ] Add \`vitest-axe\` or \`@axe-core/react\` to test suite
- [ ] Run axe on: login page, dashboard overview, pay page, payment list
- [ ] CI fails on any axe violation above minor severity"

i "a11y: color contrast ratio not verified — brand colors may fail WCAG AA" "The custom brand color scale in \`tailwind.config.ts\` has not been verified for WCAG AA contrast ratios (4.5:1 for normal text).

**Acceptance criteria:**
- [ ] Audit all brand color combinations used for text/background
- [ ] Fix any combination that fails WCAG AA
- [ ] Document passing ratios in design system"

i "a11y: interactive elements on pay page have no visible focus ring in Safari" "Safari removes default focus rings on click. The pay page interactive elements (copy button, wallet link) may have no visible focus indicator in Safari.

**Acceptance criteria:**
- [ ] All interactive elements have a visible focus ring (\`:focus-visible\` CSS)
- [ ] Focus ring meets WCAG 2.1 non-text contrast (3:1)
- [ ] Manual test in Safari 17"

i "a11y: page titles not set per route — all pages show 'DupDub' in browser tab" "No \`<title>\` or Next.js \`metadata\` is set per page. All tabs show 'DupDub', making it impossible to distinguish tabs.

**Acceptance criteria:**
- [ ] Set \`metadata.title\` per page: e.g. 'Payments — DupDub Dashboard'
- [ ] Dynamic titles for detail pages: e.g. 'Payment PAY-123 — DupDub'
- [ ] Title shown in browser history and tab"

i "a11y: form validation errors not announced to screen readers via aria-live" "Validation errors that appear after form submission are not announced by screen readers. Users hear nothing when errors appear.

**Acceptance criteria:**
- [ ] Wrap form error summary in \`aria-live='polite'\`
- [ ] Scroll to and focus first error field after failed submission
- [ ] Accessibility test asserting errors are announced"

i "a11y: table on payments list has no column headers — screen readers cannot identify columns" "The payments list table may be missing \`<th scope='col'>\` elements, making column context inaccessible.

**Acceptance criteria:**
- [ ] All columns have \`<th scope='col'>\` with descriptive text
- [ ] Row checkboxes have \`aria-label='Select payment [reference]'\`
- [ ] Accessibility test"

i "performance: no code splitting on dashboard routes — all dashboard JS loaded on first visit" "The entire dashboard bundle loads on the first page visit including analytics charts, webhook management, and settings — most of which the user may never visit.

**Acceptance criteria:**
- [ ] Verify Next.js App Router per-route code splitting is working
- [ ] Lazy-load recharts (chart library) only on analytics page
- [ ] Measure and document bundle size reduction"

i "performance: Axios instance not shared — multiple imports create multiple instances" "If \`api.ts\` is imported in multiple components, verify the Axios instance is a module-level singleton and not recreated per import.

**Acceptance criteria:**
- [ ] Confirm single Axios instance created once at module level
- [ ] Add singleton assertion test
- [ ] Document instance sharing in api.ts comments"

i "performance: analytics charts re-render on every parent state change — no memoization" "Recharts components inside analytics page re-render on every state update (e.g. filter change) even when chart data hasn't changed.

**Acceptance criteria:**
- [ ] Wrap chart components in \`React.memo\`
- [ ] Memoize data transformation functions with \`useMemo\`
- [ ] Profile with React DevTools and document render count reduction"

i "performance: payment list fetches all items and then paginates client-side" "If the payments list fetches all payments and paginates in memory, it wastes bandwidth and memory for merchants with thousands of payments.

**Acceptance criteria:**
- [ ] Confirm pagination is server-side (\`?page=N&limit=20\` on the API call)
- [ ] Never fetch more than \`limit\` rows at once
- [ ] Add test asserting correct query params sent"

i "performance: no image optimization — future merchant logo/avatar images will not use next/image" "README documents that \`next/image\` should be used for all images, but no enforcement exists. Developers may add \`<img>\` tags.

**Acceptance criteria:**
- [ ] Add ESLint rule \`@next/next/no-img-element\` to enforce next/image usage
- [ ] CI fails on \`<img>\` tags outside of next/image
- [ ] Document the rule in CONTRIBUTING.md"

i "performance: no HTTP caching headers on analytics API responses — refetches on every navigation" "Every time the merchant navigates back to the analytics page the full dataset is re-fetched. Backend has a 5-minute cache but the frontend always sends a fresh request.

**Acceptance criteria:**
- [ ] Use SWR or React Query for analytics data with \`staleTime: 5 * 60 * 1000\`
- [ ] Show stale data while revalidating in background
- [ ] Loading indicator only on first fetch, not revalidation"

i "testing: no tests for Axios request interceptor auth header injection" "The request interceptor that attaches the Bearer token has no test coverage.

**Acceptance criteria:**
- [ ] Test: request includes Authorization header when token exists
- [ ] Test: request has no Authorization header when logged out
- [ ] Test: header value matches stored token"

i "testing: no tests for Axios response interceptor 401 logout behavior" "The response interceptor that calls logout on 401 has no test coverage.

**Acceptance criteria:**
- [ ] Test: 401 response triggers logout()
- [ ] Test: 401 response triggers redirect to /auth/login
- [ ] Test: non-401 errors do not trigger logout"

i "testing: no tests for Zustand auth store persistence and rehydration" "The auth store uses Zustand persist but no tests verify the store correctly hydrates from localStorage on page reload.

**Acceptance criteria:**
- [ ] Test: store rehydrates token from localStorage on init
- [ ] Test: logout clears localStorage entry
- [ ] Test: store state matches persisted value after hydration"

i "testing: pay page polling tests do not cover exponential backoff" "Existing pay page tests cover polling but not the backoff behavior specified in requirements.

**Acceptance criteria:**
- [ ] Test: interval increases after 10 rapid polls
- [ ] Test: polling stops after 15-minute timeout
- [ ] Test: polling resumes on tab focus"

i "testing: no tests for dashboard stats calculation utility" "The \`dashboard-stats.ts\` utility has a test file but coverage may not include edge cases like zero payments or null volume.

**Acceptance criteria:**
- [ ] Test: zero payments returns 0% conversion rate (not NaN or Infinity)
- [ ] Test: null/undefined volume fields handled gracefully
- [ ] Test: percentage change calculation for 0 → non-zero"

i "testing: no tests for countries utility — invalid country codes not tested" "\`countries.ts\` utility has tests but edge cases (empty string, numeric code, unsupported country) may not be covered.

**Acceptance criteria:**
- [ ] Test: empty string returns default
- [ ] Test: unsupported country returns undefined/null
- [ ] Test: case-insensitive lookup"

i "testing: no snapshot tests for core UI components" "No snapshot tests exist for Modal, Skeleton, FormField, or ConfirmDialog, making visual regressions undetectable.

**Acceptance criteria:**
- [ ] Snapshot test for each core component in its default state
- [ ] Snapshot for each significant variant (error state, loading state)
- [ ] Snapshots updated via \`vitest -u\` on intentional UI changes"

i "testing: no test for getErrorMessage with all backend error shapes" "\`errors.ts\` handles multiple error shapes but tests may not cover all backend error formats (Axios error, plain Error, string, unknown).

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

i "testing: dashboard nav active state has tests but not for all route patterns" "Nav active state tests exist but may not cover nested routes (e.g. /dashboard/payments/[id] should activate the Payments nav item).

**Acceptance criteria:**
- [ ] Test: /dashboard/payments/[id] activates Payments nav item
- [ ] Test: /dashboard/settlements/[id] activates Settlements nav item
- [ ] Test: exact match vs prefix match distinction"

i "testing: no tests for middleware — unauthenticated redirect not covered" "\`src/middleware.ts\` redirects unauthenticated users to /auth/login but has no test coverage.

**Acceptance criteria:**
- [ ] Test: request to /dashboard without token redirects to /auth/login
- [ ] Test: request to /pay/[id] without token is allowed through
- [ ] Test: authenticated request to /auth/login redirects to /dashboard"

i "testing: no tests for auth-redirect utility" "\`auth-redirect.ts\` has a test file but verify all redirect cases are covered.

**Acceptance criteria:**
- [ ] Test: authenticated user visiting /auth/login is redirected to /dashboard
- [ ] Test: unauthenticated user visiting /dashboard is redirected to /auth/login
- [ ] Test: ?next= param is preserved and validated"

i "testing: no tests for env validation — invalid env vars silently accepted" "\`env.ts\` validates required env vars but tests may not cover all invalid inputs.

**Acceptance criteria:**
- [ ] Test: missing NEXT_PUBLIC_API_URL in production throws
- [ ] Test: invalid URL format is rejected
- [ ] Test: valid config passes without error"

i "dx: no CONTRIBUTING.md — new contributors have no onboarding guide" "No contribution guide exists for the frontend repo.

**Acceptance criteria:**
- [ ] CONTRIBUTING.md: branch naming, PR process, test requirements, design conventions
- [ ] PR template in .github/pull_request_template.md"

i "dx: TypeScript strict mode not enabled — potential runtime errors hidden" "\`tsconfig.json\` may not have \`strict: true\`, leaving \`strictNullChecks\` and \`noImplicitAny\` disabled.

**Acceptance criteria:**
- [ ] Enable \`strict: true\` in tsconfig.json
- [ ] Fix all resulting type errors
- [ ] CI type-check step must pass"

i "dx: no husky pre-commit hook — lint and type-check not enforced before commit" "Developers can commit code that fails lint or type-check. CI is the only gate.

**Acceptance criteria:**
- [ ] husky + lint-staged: run \`next lint\` on staged files
- [ ] Run \`tsc --noEmit\` on pre-commit
- [ ] Setup documented in CONTRIBUTING.md"

i "dx: no .github/CODEOWNERS file — PRs have no automatic reviewer assignment" "No CODEOWNERS file exists. PRs require manual reviewer assignment every time.

**Acceptance criteria:**
- [ ] .github/CODEOWNERS assigning reviewers for src/app, src/lib, src/components
- [ ] Reviewed by at least one owner before merge"

i "dx: Tailwind brand colors not documented — new developers use arbitrary colors" "The custom brand color scale in \`tailwind.config.ts\` is not documented. Developers may use arbitrary hex values instead of the design system colors.

**Acceptance criteria:**
- [ ] Document all brand colors in a design-system.md or Storybook
- [ ] Add Tailwind lint rule (tailwind-class-sorter or similar) to enforce consistent usage
- [ ] README link to color documentation"

i "dx: no Storybook or component library — UI components developed in isolation is impossible" "No Storybook is set up. Developers cannot view or test components in isolation without running the full app.

**Acceptance criteria:**
- [ ] Set up Storybook with Next.js integration
- [ ] Stories for: Modal, FormField, Skeleton, ConfirmDialog, StatusBadge
- [ ] CI step to build Storybook and check for errors"

i "dx: vitest config has no coverage threshold — test coverage can silently drop to 0" "No coverage threshold is set in \`vitest.config.ts\`.

**Acceptance criteria:**
- [ ] Set coverage thresholds: lines 70%, functions 70%, branches 60%
- [ ] CI fails if coverage drops below threshold
- [ ] Coverage badge in README"

i "dx: no CHANGELOG.md — breaking changes undocumented" "No changelog exists. API or behavior changes are undiscoverable without reading git history.

**Acceptance criteria:**
- [ ] CHANGELOG.md with entries for all breaking changes
- [ ] Conventional commits enforced via commitlint"

i "dx: ESLint config uses deprecated rules — no @typescript-eslint/recommended-type-checked" "The ESLint config may not include TypeScript-aware linting rules that catch type errors at lint time.

**Acceptance criteria:**
- [ ] Enable \`@typescript-eslint/recommended-type-checked\`
- [ ] Fix all new violations
- [ ] CI lint step must pass"

i "dx: no docker-compose for local dev — backend must be run separately" "Developers need to run the backend separately. No Docker Compose ties the frontend, backend, and their dependencies together.

**Acceptance criteria:**
- [ ] docker-compose.dev.yml that starts frontend, backend, Postgres, and Redis
- [ ] README updated with single-command full-stack setup"

i "security: Content-Security-Policy in next.config.js does not include connect-src for API domain" "The CSP header may not include a \`connect-src\` directive covering the backend API domain. API calls would be blocked in strict CSP environments.

**Acceptance criteria:**
- [ ] Add \`connect-src 'self' \${NEXT_PUBLIC_API_URL}\` to CSP
- [ ] Add \`connect-src wss://...\` for WebSocket connection
- [ ] E2E test with CSP reporting enabled"

i "security: X-Frame-Options set to DENY — payment embed use case blocked" "If merchants want to embed the pay page in an iframe on their storefront, the DENY policy blocks it. SAMEORIGIN or a specific allowlist would be more flexible.

**Acceptance criteria:**
- [ ] Change to SAMEORIGIN or add configurable ALLOW-FROM
- [ ] Document the tradeoff between security and embed use case
- [ ] Add \`frame-ancestors\` CSP directive"

i "security: no Subresource Integrity (SRI) for any CDN-loaded resources" "If any third-party scripts or stylesheets are loaded from a CDN without SRI hashes, they can be compromised without detection.

**Acceptance criteria:**
- [ ] Audit all external resource loads
- [ ] Add integrity and crossorigin attributes where applicable
- [ ] Or move all resources to self-hosted"

i "security: Zustand store not cleared on login from a different account — stale state persists" "If merchant A logs out and merchant B logs in on the same browser, the old store state may persist (cached payment lists, etc.) before the new user's data loads.

**Acceptance criteria:**
- [ ] Clear all non-auth Zustand stores on logout
- [ ] Clear all SWR/React Query caches on logout
- [ ] Unit test: login after logout shows no previous user's data"

i "security: payment reference in URL is predictable — PAY-{timestamp}-{random} enumerable" "The pay page URL is \`/pay/[paymentId]\` where paymentId is a UUID (not guessable). But if the reference is ever used in URLs, the timestamp-based format is enumerable.

**Acceptance criteria:**
- [ ] Confirm pay page uses UUID (not reference) in URL
- [ ] If reference is used in any URL, replace with UUID
- [ ] Document URL strategy in README"

i "security: no rate limit on frontend login form submissions — brute-force via UI possible" "The frontend login form has no debounce or submission rate limiting. A script can hammer the backend login endpoint via the UI.

**Acceptance criteria:**
- [ ] Disable submit button for 2s after each failed attempt
- [ ] Show lockout message when backend returns lockout error
- [ ] Unit test for lockout error display"

i "security: merchant data in localStorage not encrypted — readable by extensions and malware" "Zustand persist stores the merchant profile object (including business name, country, role) in plaintext localStorage.

**Acceptance criteria:**
- [ ] Store only the token in localStorage (minimum necessary)
- [ ] Remove merchant profile from persisted state; fetch on-demand
- [ ] Or encrypt persisted data with a session-derived key"

i "i18n: all user-facing strings hardcoded in English — no i18n framework" "All user-facing text is hardcoded in English. The platform serves international merchants but provides no localization.

**Acceptance criteria:**
- [ ] Set up next-intl or react-i18next
- [ ] Extract all hardcoded strings to translation files
- [ ] Support at least: English, French, Portuguese (for NG/BR/FR merchant base)"

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

i "i18n: payment status labels not translatable — PENDING, CONFIRMED, etc. shown as raw enum values" "Payment status values from the backend are displayed directly without mapping to human-readable labels.

**Acceptance criteria:**
- [ ] Map all status enum values to display labels
- [ ] Labels should be translatable in i18n framework
- [ ] Unit test for each status mapping"

i "ux: payment creation form resets on API error — merchant loses all entered data" "If payment creation fails, the form resets to empty. The merchant must re-enter all fields.

**Acceptance criteria:**
- [ ] Preserve form values on API error
- [ ] Show specific error message from API (e.g. 'Amount exceeds maximum')
- [ ] Unit test: form values preserved after failed submit"

i "ux: no confirm step before payment creation — accidental submissions create real payments" "The payment creation form submits immediately on clicking 'Create Payment' with no confirmation step. Accidental submissions create live payment requests.

**Acceptance criteria:**
- [ ] Show a confirmation summary: 'Create a payment for \$25.00?' with Confirm/Cancel
- [ ] Use ConfirmDialog component
- [ ] Unit test for confirmation flow"

i "ux: settlement list does not show linked payment count — merchants cannot understand what is included" "The settlement list shows gross/net amounts but not how many payments were batched into each settlement.

**Acceptance criteria:**
- [ ] Show payment count per settlement row
- [ ] Clicking the count opens a panel listing the linked payments
- [ ] Unit test for count display"

i "ux: no onboarding flow for new merchants — dashboard is empty with no guidance" "New merchants land on an empty dashboard with no onboarding steps, checklist, or tooltip tour.

**Acceptance criteria:**
- [ ] 5-step onboarding checklist: complete profile, add bank account, create test payment, set up webhook, go live
- [ ] Checklist persists in localStorage until all steps done
- [ ] Each step links to the relevant settings or action"

i "ux: webhook creation form has no event subscription preview — merchants don't know what each event means" "The webhook creation form lists event names (payment.confirmed, settlement.completed) with no description or payload preview.

**Acceptance criteria:**
- [ ] Tooltip or expandable section per event name with description and sample payload
- [ ] Link to webhook documentation
- [ ] Unit test for event description display"

i "ux: no breadcrumb navigation on nested dashboard pages — users lose context" "On nested pages like /dashboard/payments/[id] there is no breadcrumb showing the navigation path.

**Acceptance criteria:**
- [ ] Breadcrumb component: Dashboard > Payments > PAY-123
- [ ] Dynamic breadcrumbs based on route
- [ ] Accessible: nav landmark with aria-label='Breadcrumb'"

i "ux: no keyboard shortcut for creating a new payment — power users require mouse" "Common actions like creating a new payment require multiple mouse clicks. No keyboard shortcuts exist.

**Acceptance criteria:**
- [ ] \`N\` key (when not in input) opens new payment modal on dashboard
- [ ] \`?\` key shows shortcuts cheatsheet
- [ ] Shortcuts documented in settings page"

i "ux: pagination controls not shown when total is unknown — first load always shows 'Page 1 of ?'" "Before data loads, the total page count is unknown, so pagination shows an incomplete state.

**Acceptance criteria:**
- [ ] Show skeleton pagination while loading
- [ ] Once loaded, show 'Page 1 of 42'
- [ ] Show total count: '847 payments'"

i "ux: amount input does not format number on blur — 25 stays as 25 instead of 25.00" "The payment amount input shows an unformatted number. Users expect currency inputs to show two decimal places.

**Acceptance criteria:**
- [ ] On blur, format to 2 decimal places (25 → 25.00)
- [ ] Show currency symbol aligned to the left of the input
- [ ] Unit test for format-on-blur behavior"

i "ux: webhook list shows URL in full — long URLs break layout on mobile" "Long webhook URLs overflow their table cell on mobile viewports, breaking the table layout.

**Acceptance criteria:**
- [ ] Truncate URLs at 50 characters with ellipsis
- [ ] Show full URL on hover (tooltip)
- [ ] Copy-to-clipboard on click
- [ ] Responsive table layout test"

i "ux: no visual indicator for sandbox mode — merchants may not know they are in test mode" "If a merchant is in sandbox mode, the dashboard looks identical to production mode. Real payments and test payments are indistinguishable at a glance.

**Acceptance criteria:**
- [ ] Show a 'Sandbox Mode' banner at the top of all dashboard pages in sandbox mode
- [ ] Banner color: yellow/amber
- [ ] 'Switch to production' CTA linking to settings"

i "ux: payment QR code on dashboard not downloadable — merchants cannot print or share it" "The QR code shown after payment creation cannot be downloaded as an image.

**Acceptance criteria:**
- [ ] 'Download QR' button saves PNG to disk
- [ ] 'Copy link' button copies the payment page URL
- [ ] Unit test for download trigger"

i "ux: no print styles — payment receipts look broken when printed" "No CSS print media query styles exist. Printing a receipt or dashboard page renders navigation, sidebars, and buttons on paper.

**Acceptance criteria:**
- [ ] Print stylesheet hides navigation, sidebar, and action buttons
- [ ] Print receipt shows only: merchant name, payment details, amount, status
- [ ] Test by opening print preview"

i "ux: settlement approval status not shown to merchant — large settlements appear stuck" "When a settlement requires admin approval, the merchant sees status PENDING_APPROVAL with no explanation.

**Acceptance criteria:**
- [ ] Display 'Awaiting approval — large settlements are manually reviewed within 24h'
- [ ] Show estimated approval time
- [ ] Email merchant when settlement is approved or rejected"

i "ux: no way for merchant to contact support from dashboard — must leave the app" "No in-app support link or chat widget exists. Merchants must find support contact externally.

**Acceptance criteria:**
- [ ] 'Help & Support' link in dashboard sidebar
- [ ] Links to docs, status page, and email support
- [ ] Optionally: in-app chat widget integration"

i "ux: payment list defaults to showing all statuses — most useful view is pending+confirmed" "The default payment list view shows all statuses mixed together. For daily operations, merchants primarily care about pending and confirmed payments.

**Acceptance criteria:**
- [ ] Default filter: PENDING + CONFIRMED (most actionable)
- [ ] 'All payments' option to remove filter
- [ ] Persist selected filter in URL"

i "ux: no mobile-optimized payment creation flow — desktop-only form UX" "The payment creation form is designed for desktop. On mobile, multi-field forms are hard to use.

**Acceptance criteria:**
- [ ] Multi-step form on mobile: amount → description → customer email → review
- [ ] Single-step form on desktop (current)
- [ ] Mobile breakpoint at 768px
- [ ] Mobile form usability test"

i "ux: dark mode not supported — merchants working at night have no alternative" "The app has no dark mode support. The white dashboard is uncomfortable in low-light environments.

**Acceptance criteria:**
- [ ] Implement dark mode using Tailwind's \`dark:\` variant
- [ ] Respect \`prefers-color-scheme\` by default
- [ ] Manual toggle in dashboard settings
- [ ] Persist preference in localStorage"

i "dx: no API mock server for local frontend dev without running backend" "Frontend developers must run the full backend stack locally. No mock server exists for frontend-only development.

**Acceptance criteria:**
- [ ] MSW (Mock Service Worker) setup for local development
- [ ] Mock handlers for all API endpoints with realistic data
- [ ] README documents how to start frontend in mock mode"

i "dx: no visual regression testing — UI changes undetected until manual review" "No visual regression tests exist. UI changes (Tailwind updates, component refactors) can silently break the visual appearance.

**Acceptance criteria:**
- [ ] Integrate Chromatic or Percy for visual regression testing
- [ ] Run on every PR against main branch
- [ ] Approve visual changes explicitly before merge"

i "dx: package.json has no \`engines\` field — wrong Node.js version used silently" "No \`engines\` field in package.json. Developers running Node 16 instead of 18 get no warning.

**Acceptance criteria:**
- [ ] Add \`'engines': { 'node': '>=18' }\` to package.json
- [ ] Add .nvmrc (already exists — verify it matches engines field)
- [ ] CI uses exact Node version from .nvmrc"

i "dx: no \`verify\` script in package.json — running type-check + lint + tests requires 3 commands" "Developers run type-check, lint, and tests separately. A single \`npm run verify\` command would speed up pre-PR checks.

**Acceptance criteria:**
- [ ] Add \`'verify': 'npm run type-check && npm run lint && npm test'\` to package.json scripts
- [ ] CI uses \`npm run verify\` as the single check command
- [ ] Document in README and CONTRIBUTING.md"

echo ""
echo "=== Frontend: 125 issues created ==="
