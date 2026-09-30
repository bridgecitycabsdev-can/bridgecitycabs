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
