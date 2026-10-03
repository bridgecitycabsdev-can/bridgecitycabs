/** Bump this when the notice text changes. Drivers must accept the new version. */
export const LOCATION_NOTICE_VERSION = '2026-10-03';

/**
 * Shown full-screen in the driver app before any location permission prompt.
 * Confirm wording and the 90-day retention with counsel (PIPEDA + Play disclosure).
 */
export const LOCATION_NOTICE = [
  'Bridge City Cabs collects your location while you are on shift, including when the app is in the background.',
  'We use it for dispatch (assigning trips), passenger tracking during your active trip, safety, and dispute resolution.',
  'Dispatch can see your live position while you are on shift. The passenger on your active trip can see your position until that trip ends.',
  'Location history is available only to a super admin or your branch admin, and each of those reads is recorded.',
  'Stored points are deleted after 90 days. That retention period is a placeholder until it is confirmed with the insurer and legal counsel.',
].join(' ');
