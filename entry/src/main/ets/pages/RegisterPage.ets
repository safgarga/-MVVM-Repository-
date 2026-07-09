import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { StorageUtil } from '../utils/StorageUtil';
import { User } from '../model/User';
import { UserRole } from '../model/User';
import { Campus } from '../model/User';

@Entry
@Component
struct RegisterPage {
  @State username: string = '';
  @State password: string = '';
  @State confirmPwd: string = '';
  @State campus: Campus = Campus.NORTH;

  private async register(): Promise<void> {
    if (!this.username || !this.password) {
      promptAction.showToast({ message: '请填写账号密码', duration: 2000 });
      return;
    }
    if (this.password !== this.confirmPwd) {
      promptAction.showToast({ message: '两次密码不一致', duration: 2000 });
      return;
    }

    // 查重
    const users = await StorageUtil.getUsers();
    if (users.find(u => u.username === this.username)) {
      promptAction.showToast({ message: '账号已存在', duration: 2000 });
      return;
    }

    const user = new User();
    user.id = `u_${Date.now()}`;
    user.username = this.username;
    user.password = this.password;
    user.role = UserRole.NORMAL;
    user.campus = this.campus;

    await StorageUtil.saveUser(user);

    promptAction.showToast({ message: '注册成功，请登录', duration: 2000 });
    setTimeout(() => router.back(), 1000);
  }

  build() {
    Column({ space: 20 }) {
      Text('注册新账号')
        .fontSize(24)
        .fontWeight(700)
        .margin({ top: 60 });

      TextInput({ placeholder: '用户名' })
        .width('80%')
        .onChange(v => this.username = v);

      TextInput({ placeholder: '密码' })
        .type(InputType.Password)
        .width('80%')
        .onChange(v => this.password = v);

      TextInput({ placeholder: '确认密码' })
        .type(InputType.Password)

        .width('80%')
        .onChange(v => this.confirmPwd = v);

      // 校区
      Row() {
        Text('校区：');
        Radio({ value: 'north', group: 'reg_campus' })
          .onChange(v => v && (this.campus = Campus.NORTH));
        Text('北校区').margin({ right: 16 });
        Radio({ value: 'south', group: 'reg_campus' })
          .onChange(v => v && (this.campus = Campus.SOUTH));
        Text('南校区');
      }

      Button('注册', { type: ButtonType.Capsule })
        .width('80%')
        .backgroundColor('#FF5000')
        .fontColor(Color.White)
        .onClick(() => this.register());

      Button('返回登录', { type: ButtonType.Capsule })
        .width('80%')
        .backgroundColor('#EEE')
        .fontColor('#333')
        .onClick(() => router.back());
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .backgroundColor('#F5F5F5');
  }
}

export { RegisterPage };