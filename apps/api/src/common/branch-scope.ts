import type { AuthUser } from './auth-user.js';

export function branchWhere(user: AuthUser, requestedBranchId?: string) {
  if (user.role === 'super_admin') {
    return requestedBranchId ? { branchId: requestedBranchId } : {};
  }
  return { branchId: user.branchId! };
}

export function branchIdForCreate(user: AuthUser, requestedBranchId?: string) {
  if (user.role === 'super_admin') {
    return requestedBranchId;
  }
  return user.branchId!;
}

/** True when the user may read branch-scoped personal/financial artifacts. */
export function canAccessBranch(user: AuthUser, branchId: string) {
  if (user.role === 'super_admin') return true;
  return Boolean(user.branchId && user.branchId === branchId);
}
