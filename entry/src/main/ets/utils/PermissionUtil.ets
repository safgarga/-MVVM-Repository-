import { StorageUtil } from './StorageUtil';
import { UserRole } from '../model/User';

export class PermissionUtil {
  static isAdmin(): boolean {
    return StorageUtil.getCurrentUserSync()?.role === UserRole.ADMIN;
  }

  static canPublish(): boolean {
    return StorageUtil.getCurrentUserSync() !== null;
  }
}