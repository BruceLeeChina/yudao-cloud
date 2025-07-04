import { Router } from 'vue-router';
import { PageEnum, PreviewEnum } from '@/enums/pageEnum'
import {getLocalStorage, loginCheck, setSessionStorage} from '@/utils'
import {useSystemStore} from "@/store/modules/systemStore/systemStore";
const viteRouter = import.meta.env.VITE_ROUTER_DEFAULT
import { SystemStoreUserInfoEnum, SystemStoreEnum } from '@/store/modules/systemStore/systemStore.d'
import {pinia} from "@/store/index"
const systemStore = useSystemStore(pinia)
// 路由白名单
const routerAllowList = [
  // 登录
  PageEnum.BASE_LOGIN_NAME,
  // 预览
  // PreviewEnum.CHART_PREVIEW_NAME
]

export function createRouterGuards(router: Router) {
  // 前置
  router.beforeEach(async (to, from, next) => {
    // http://localhost:3000/#/chart/preview/792622755697790976?t=123
    // 把外部动态参数放入window.route.params，后续API动态接口可以用window.route?.params?.t来拼接参数
    // @ts-ignore
    if (!window.route) window.route = {params: {}}
    // @ts-ignore
    Object.assign(window.route.params, to.query)

    const Loading = window['$loading'];
    Loading && Loading.start();
    const isErrorPage = router.getRoutes().findIndex((item) => item.name === to.name);
    if (isErrorPage === -1) {
      next({ name: PageEnum.ERROR_PAGE_NAME_404 })
      return
    }
    if (!routerAllowList.includes(<PageEnum>to.name)&&!loginCheck()) {
        if(PreviewEnum.CHART_PREVIEW_NAME === to.name&& viteRouter==='false'){
          setSessionStorage('setRedirectPath','/chart/preview')
          setSessionStorage('setRedirectPathId',to.params.id[0])
        }
        next({ name: PageEnum.BASE_LOGIN_NAME })
    }
    next()
  })

  router.afterEach((to, _, failure) => {
    const Loading = window['$loading'];
    document.title = (to?.meta?.title as string) || document.title;
    Loading && Loading.finish();
  })

  // 错误
  router.onError((error) => {
    console.log(error, '路由错误');
  });

  // 如果有 accessToken 和 refreshToken 参数，进行自动登录
  const searchParams = new URL(location.href).searchParams;
  if (searchParams.get('accessToken') && searchParams.get('refreshToken')) {
    systemStore.setItem(SystemStoreEnum.USER_INFO, {
      // @ts-ignore
      [SystemStoreUserInfoEnum.USER_TOKEN]: searchParams.get('accessToken'),
      // @ts-ignore
      [SystemStoreUserInfoEnum.USER_REFRESH_TOKEN]: searchParams.get('refreshToken'),
      [SystemStoreUserInfoEnum.TOKEN_NAME]: "Authorization",
    })
  }
}