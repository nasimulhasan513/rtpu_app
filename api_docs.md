### User APIs (Non-Admin)

Below are the user-related server endpoints for the app. All paths are under `/api`. Cookies are used for session auth where required.

- **Auth/session**: Uses http-only cookie set on successful login/social login. Include the cookie in subsequent requests.
- **Validation**: Zod schemas (via `h3-zod`) are used where noted.

---

#### POST `/auth/signin`
- **Auth**: No
- **Body**:
  - **cred**: string (email or phone)
  - **password**: string (6–255 chars)
  - **type**: "email" | "phone"
- **Behavior**: Verifies user by email/phone and password. Creates a session and sets auth cookie.
- **Responses**:
  - 200: `true`
  - 400: "Invalid password" | "Incorrect email or password"
  - 404: "User not found"

#### POST `/auth/google`
- **Auth**: No
- **Body**:
  - **accessToken**: string (Google ID token)
- **Behavior**: Verifies Google token. If user exists, updates missing image, deletes other sessions, creates a new session. Otherwise creates user and session. Sets auth cookie.
- **Responses**:
  - 200: `true`
  - 400/500 on verification or internal errors

#### POST `/logout`
- **Auth**: Yes (session required)
- **Body**: none
- **Behavior**: Invalidates current session and clears cookie.
- **Responses**: 200: `true`; 403 if no session

#### GET `/user`
- **Auth**: Yes
- **Query**: none
- **Behavior**: Returns the currently authenticated user from `event.context.user`.
- **Responses**: 200: `User | null`

#### PUT `/auth/profile`
- **Auth**: Yes
- **Body**: `{ name?, institute?, phone?, hsc_batch? }`
- **Behavior**: Updates current user profile fields.
- **Responses**: 200: "Profile updated successfully"; 401 if unauthenticated

#### POST `/auth/update`
- **Auth**: Yes
- **Validation**: `SignupSchema` (Zod)
- **Body** (per schema): `{ phone, institute, hsc_batch }`
- **Behavior**: Updates current user fields, normalizes phone number, and refreshes `event.context.user` from session.
- **Responses**: 200: `true`; 400 with validation errors

#### POST `/auth/exists`
- **Auth**: No
- **Body**: `{ email: string }`
- **Behavior**: Checks if a user with the given email exists.
- **Responses**: 200: `{ user }`; 400 if not found

#### POST `/auth/update_pic`
- **Auth**: Yes
- **Body**: `{ fileName: string, fileSize?: number, fileType?: string }`
- **Behavior**: Generates a signed S3 upload URL and pre-updates the user `image` to the S3 object path.
- **Responses**: 200: `{ uploadUrl: string }`; 4xx/5xx on errors or missing AWS config

#### GET `/auth/:id`
- **Auth**: Yes (expects `event.context.params.id`)
- **Query**: `slug` (course slug)
- **Behavior**: Returns per-course progress, lesson completion, exam submission stats, and assignment completion for the specified user and course.
- **Responses**: 200: progress payload; 400: missing slug; 401: unauthorized; 404: not enrolled/not found

#### PUT `/user` (index)
- **Auth**: Intended Yes
- **Validation**: `profileUpdateSchema` (referenced)
- **Status**: Currently stubbed with try/catch and 400 error; implement to update profile via schema.

---

### Notes
- Some endpoints under `/auth` can be admin-scoped by role guards even if not in `admin` folder. For app client usage, prefer endpoints listed above and ensure a valid session cookie when `Auth: Yes` is required.
- Phone normalization in `/auth/update` trims, digits-only, last 10 digits, then prefixes with `+880`.
