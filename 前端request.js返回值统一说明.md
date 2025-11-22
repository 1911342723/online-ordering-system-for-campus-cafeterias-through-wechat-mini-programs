# ⚠️ 前端 request.js 返回值统一说明

## 核心规则

**`request.js` 在成功时直接返回后端的 `data` 字段，不是完整的响应对象！**

```javascript
// request.js 中的处理逻辑
if (code === 1) {
  resolve(data)  // ✅ 直接返回 data
} else {
  reject(res.data)  // ❌ 失败时reject整个res.data
}
```

## ❌ 错误用法

```javascript
const res = await request({ url: '/user/info', method: 'GET' })

// ❌ 错误：res 已经是 data，不需要再取 .data
if (res && res.data) {
  console.log(res.data.balance)  // undefined!
}
```

## ✅ 正确用法

```javascript
const res = await request({ url: '/user/info', method: 'GET' })

// ✅ 正确：res 就是后端返回的 data
if (res) {
  console.log(res.balance)  // 正确获取
}
```

## 后端响应结构

```json
{
  "code": 1,
  "msg": "success",
  "data": {
    "balance": 2000.00,
    "name": "用户0231"
  }
}
```

**前端 `request.js` 处理后：**
```javascript
// resolve 的是 data 部分，不是整个响应
{
  "balance": 2000.00,
  "name": "用户0231"
}
```

## 已修复的文件清单

### ✅ 已修复
1. `frontend/user/pages/payment/payment.js`
   - `loadOrderInfo()` - 获取订单信息
   - `loadUserBalance()` - 获取用户余额
   - `payByBalance()` - 余额支付
   - `payByMock()` - 模拟支付

2. `frontend/user/pages/recharge/recharge.js`
   - `loadUserBalance()` - 获取余额
   - `submitRecharge()` - 提交充值

3. `frontend/user/pages/address/list.js`
   - `loadAddressList()` - 获取地址列表

4. `frontend/user/pages/address/edit.js`
   - `loadAddressDetail()` - 获取地址详情

### 🔍 检查要点

在所有使用 `request()` 的地方，检查：

1. **不要使用 `res.data`** - 直接使用 `res`
2. **判断条件** - `if (res)` 而不是 `if (res && res.data)`
3. **访问字段** - `res.balance` 而不是 `res.data.balance`
4. **数组判断** - `Array.isArray(res)` 而不是 `Array.isArray(res.data)`

## 示例对比

### 获取订单列表

❌ **错误：**
```javascript
const result = await request({ url: '/order/userPage' })
if (result && result.records) {
  // result 已经是后端的 data（Page对象）
  this.setData({ orders: result.records })  // ✅
}
```

✅ **正确：**
```javascript
const result = await request({ url: '/order/userPage' })
if (result && result.records) {
  this.setData({ orders: result.records })
}
```

### 获取单个对象

❌ **错误：**
```javascript
const res = await request({ url: '/user/info' })
if (res && res.data && res.data.success) {
  console.log(res.data.balance)  // undefined
}
```

✅ **正确：**
```javascript
const res = await request({ url: '/user/info' })
if (res) {
  console.log(res.balance)
}
```

### 获取数组

❌ **错误：**
```javascript
const res = await request({ url: '/addressBook/list' })
if (res && res.data) {
  this.setData({ list: res.data })  // res.data 是 undefined
}
```

✅ **正确：**
```javascript
const res = await request({ url: '/addressBook/list' })
if (res) {
  this.setData({ list: Array.isArray(res) ? res : [] })
}
```

## 总结

**记住：`request.js` 已经帮你解包了，直接用返回值就好！**

- `resolve(data)` → 返回的就是 `data`
- 不需要 `.data.data`
- 不需要 `res.data.xxx`
- 直接用 `res.xxx`

