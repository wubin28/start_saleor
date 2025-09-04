# Discount testing using decision tables

## Checkout折扣码应用决策表

### 条件定义

| 条件编号 | 条件描述 | 可能值 |
|---------|---------|--------|
| C1 | 订单中是否有Catalogue Promotion | Y / N |
| C2 | 输入的折扣码类型 | ENTIRE_ORDER / SPECIFIC_PRODUCT / SHIPPING / INVALID / NONE |
| C3 | 折扣码状态 | VALID / EXPIRED / USAGE_LIMIT_REACHED / INACTIVE |
| C4 | 订单金额是否满足最小要求 | Y / N |
| C5 | 产品是否符合特定产品券条件 | Y / N / NA |

### 动作定义

| 动作编号 | 动作描述 |
|---------|---------|
| A1 | 显示折扣应用成功 |
| A2 | 更新订单小计金额 |
| A3 | 更新运费金额 |
| A4 | 显示促销组合效果 |
| A5 | 显示错误信息 |
| A6 | 保持原价格不变 |

### 决策表

| 规则 | R1 | R2 | R3 | R4 | R5 | R6 | R7 | R8 | R9 | R10 | R11 | R12 |
|------|----|----|----|----|----|----|----|----|----|----|----|----|
| **条件** |
| C1: 有Catalogue Promotion | N | N | N | Y | Y | Y | N | N | N | N | Y | N |
| C2: 折扣码类型 | NONE | ENTIRE_ORDER | SPECIFIC_PRODUCT | ENTIRE_ORDER | SPECIFIC_PRODUCT | SHIPPING | SHIPPING | INVALID | ENTIRE_ORDER | SPECIFIC_PRODUCT | ENTIRE_ORDER | ENTIRE_ORDER |
| C3: 折扣码状态 | NA | VALID | VALID | VALID | VALID | VALID | VALID | NA | EXPIRED | VALID | VALID | VALID |
| C4: 满足最小金额要求 | NA | Y | Y | Y | Y | NA | NA | NA | Y | N | Y | N |
| C5: 产品符合特定券条件 | NA | NA | Y | NA | Y | NA | NA | NA | NA | Y | NA | NA |
| **动作** |
| A1: 显示成功 | | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | | | | ✓ | |
| A2: 更新订单小计 | | ✓ | ✓ | ✓ | ✓ | | | | | | ✓ | |
| A3: 更新运费 | | | | | | ✓ | ✓ | | | | | |
| A4: 显示组合效果 | | | | ✓ | ✓ | ✓ | | | | | ✓ | |
| A5: 显示错误信息 | | | | | | | | ✓ | ✓ | ✓ | | ✓ |
| A6: 保持原价格 | ✓ | | | | | | | ✓ | ✓ | ✓ | | ✓ |

### 规则说明

- **R1**: 基准场景 - 无任何折扣
- **R2**: 仅使用整单折扣券
- **R3**: 仅使用特定产品折扣券
- **R4**: Catalogue Promotion + 整单折扣券组合
- **R5**: Catalogue Promotion + 特定产品折扣券组合
- **R6**: Catalogue Promotion + 运费折扣券组合
- **R7**: 仅使用运费折扣券
- **R8**: 无效折扣码
- **R9**: 过期折扣码
- **R10**: 产品不符合特定券条件
- **R11**: Catalogue Promotion + 整单券（满足条件）
- **R12**: 整单券不满足最小金额要求