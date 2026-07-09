import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { StorageUtil } from '../utils/StorageUtil';

@Entry
@Component
struct LoginPage {
  @State username: string = '';
  @State password: string = '';

  private login(): void {
    if (!this.username || !this.password) {
      promptAction.showToast({ message: '请输入账号密码' });
      return;
    }

    StorageUtil.getUsers().then((users) => {
      const user = users.find(
        u => u.username === this.username && u.password === this.password
      );

      if (!user) {
        promptAction.showToast({ message: '账号密码错误' });
        return;
      }

      StorageUtil.setCurrentUser(user);
      router.replaceUrl({ url: 'pages/Index' });
    });
  }
  build() {
    Column({ space: 20 }) {
      Text('校园二手交易平台').fontSize(24).fontWeight(700).margin({ top: 60 });
      TextInput({ placeholder: '用户名' }).width('80%').onChange(v => this.username = v);
      TextInput({ placeholder: '密码' }).width('80%').type(InputType.Password).onChange(v => this.password = v);
      Button('登录').width('80%').backgroundColor('#FF5000').onClick(() => this.login());
      Text('没有账号？去注册')
        .fontSize(14)
        .fontColor('#007DFF')
        .margin({ top: 10 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/RegisterPage' });
        });
      Text('默认账号：\nuser/123456（普通用户）\nadmin/123456（管理员）')
        .fontSize(12).fontColor('#999').margin({ top: 20 });
    }
    .width('100%').height('100%').justifyContent(FlexAlign.Center).backgroundColor('#F5F5F5');
  }
}