/** Access token for this tab. The refresh token stays in the httpOnly cookie. */
let accessToken: string | null = null

export function getAccessToken() {
  return accessToken
}

export function setAccessToken(token: string | null) {
  accessToken = token
}
