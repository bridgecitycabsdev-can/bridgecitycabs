/** Bump this when the notice text changes. Drivers must accept the new version. */
export const LOCATION_NOTICE_VERSION = '2026-09-30';

/**
 * Shown in the driver app before a shift, and stored as the agreement they accept.
 * The 90-day period is a placeholder until the insurer and legal counsel confirm it.
 */
export const LOCATION_NOTICE = [
  'Bridgecabs collects your location only while you are on shift.',
  'Dispatch uses it to assign trips, and the passenger on your active trip can see your position until that trip ends.',
  'Location history is available only to a super admin or your branch admin, and each of those reads is recorded.',
  'Stored points are deleted after 90 days. That period is a placeholder until it is confirmed with the insurer and legal counsel.',
].join(' ');
