# Order Flow Test Guide

## Objective
Verify the full user order flow is correct from submit -> pay -> merchant accept -> ready -> completed.

## Expected Status Flow
- `1`: 待付款
- `2`: 待接单
- `3`: 制作中
- `4`: 待取餐/派送中
- `5`: 已完成
- `6`: 已取消

Allowed transitions in backend:
- `2 -> 3 -> 4 -> 5`
- `2 -> 6`
- `3 -> 6`

## Automated Tests
Backend unit tests were added:
- `backend/src/test/java/com/java_project/reggie/controller/OrderStatusFlowTest.java`
- `backend/src/test/java/com/java_project/reggie/controller/PaymentFlowTest.java`

They cover:
- Merchant accept status update without rollback
- Illegal transition rejection
- Transition to ready/completed
- Balance payment unit consistency (分/元)

## Manual End-to-End Check
1. User submits order from mini-program checkout.
2. Confirm DB status is `1` (待付款).
3. User pays order.
4. Confirm DB status changes to `2` (or `3` if auto-accept enabled).
5. Merchant clicks 接单.
6. Confirm DB status changes to `3`.
7. Merchant clicks 待取餐.
8. Confirm DB status changes to `4`.
9. Merchant clicks 完成.
10. Confirm DB status changes to `5`.

## SQL Verification
```sql
SELECT id, number, user_id, merchant_id, status, order_time, checkout_time, accepted_time, completed_time
FROM orders
WHERE id = ?;
```

## Troubleshooting
- If merchant clicks 接单 and status stays `2`, check backend logs for `/order` update request and returned code.
- If response is success but DB unchanged, verify backend service has been restarted with latest code.
- If mini-program still shows old status, pull-to-refresh order page and verify `GET /order/userPage` response status value.
