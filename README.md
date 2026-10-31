# qtaccount · 量潮账号中心（已拆分迁移，停止演进）

> **本仓已按域拆分，不再演进**（2026-11 起）。原「账号 + 钱包」双 tab 一体客户端拆为两个用户端客户端：
>
> - **账号侧**（登录、账号信息、修改密码）→ `qtcloud-auth/src/lite`（量潮账号中心 lite）
> - **钱包侧**（余额、交易流水）→ `qtcloud-pay/src/lite`（量潮钱包 lite）
>
> 企业管理账号信息的后台系统走 `qtcloud-auth/src/studio`。新功能请去对应仓开发；本仓仅保留历史。

原说明：量潮账号中心前台——账号/钱包管理，复用 qtcloud-auth/qtcloud-pay。
