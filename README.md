# FDI对中国产业结构升级的影响研究（纯Stata项目）
## Impact of FDI on China's Industrial Structure Upgrading (Pure Stata)
### ——基于省际面板数据的实证分析
#### Evidence from Chinese Provincial Panel Data
---

### 📖 项目简介 / Project Overview

外商直接投资（FDI）是推动发展中国家产业结构升级的重要因素。本项目**完全使用Stata**完成从数据导入、清洗、变量构造、可视化到面板数据回归分析的全流程实证研究。采用2010-2022年中国31个省份的面板数据（共403个观测值），运用混合OLS、固定效应、随机效应模型，结合Hausman检验进行模型选择，并进行多重稳健性检验和分地区异质性分析。

This project is **entirely implemented in Stata** (no Python dependency), covering data import, cleaning, variable construction, visualization, and panel data regression. We use panel data from 31 Chinese provinces (403 observations, 2010-2022) with Pooled OLS, Fixed Effects, and Random Effects models, along with the Hausman test, robustness checks, and heterogeneity analysis.

**数据来源 / Data Sources:**
- 国家统计局 (National Bureau of Statistics of China)
- 《中国统计年鉴》历年数据 (China Statistical Yearbook)
- 各省份统计年鉴 (Provincial Statistical Yearbooks)
- 商务部外商投资统计 (MOFCOM FDI Statistics)

---

### 🛠 技术栈 / Tech Stack

| 类别 | 工具 | 用途 |
|------|------|------|
| 数据处理 | Stata MP 19 | 数据导入、清洗、变量构造 |
| 数据可视化 | Stata (graph) | 趋势图、散点图、箱线图、双轴图 |
| 计量分析 | Stata (xtreg) | 面板回归、Hausman检验、稳健性检验 |
| 结果输出 | esttab (Stata) | 专业回归表格生成（RTF格式） |

> **本项目为纯Stata项目，不包含任何Python代码**
> **This is a pure Stata project with no Python code**

---

### 📁 项目结构 / Project Structure

```
project2_fdi_industry/
├── code/
│   ├── 01_data_preparation.do       # Stata: 数据导入、清洗、变量构造、可视化
│   └── 02_panel_regression.do       # Stata: 面板回归、Hausman检验、稳健性、异质性
├── data/
│   ├── fdi_panel_data_raw.csv       # 原始面板数据 (Raw panel data)
│   ├── fdi_panel_data_clean.dta     # 清洗后数据 (Stata格式, 由01生成)
│   └── fdi_panel_data_clean.csv     # CSV格式 (由01生成)
├── output/
│   ├── figures/                     # 图表 (Figures - Stata graph export)
│   │   ├── fig1_ts_trend.png             # 产业结构趋势图
│   │   ├── fig2_fdi_ts_scatter.png       # FDI散点图
│   │   ├── fig3_fdi_region_trend.png     # 分地区FDI趋势
│   │   ├── fig4_fdi_ts_dual.png          # FDI与产业结构双轴图
│   │   └── fig5_tertiary_boxplot.png     # 三产占比箱线图
│   └── tables/                      # 回归表格 (Regression tables - RTF)
│       ├── table1_descriptive_stats.rtf  # 描述性统计
│       ├── table1b_region_stats.rtf      # 分地区统计
│       ├── table2_baseline_regression.rtf # 基准回归(OLS/FE/RE)
│       ├── table3_hausman_test.rtf       # Hausman检验
│       ├── table4_robustness_check.rtf   # 稳健性检验
│       └── table5_heterogeneity.rtf      # 分地区异质性分析
└── README.md
```

---

### 🚀 如何运行 / How to Run

```
* 在Stata命令行中依次执行 / Run in Stata command window:

* 步骤1：数据导入、清洗与可视化
cd "你的路径/project2_fdi_industry"
do code/01_data_preparation.do

* 步骤2：面板回归分析
do code/02_panel_regression.do
```

> **注意：必须先运行01_data_preparation.do生成fdi_panel_data_clean.dta，再运行02_panel_regression.do**
> **Note: Run 01_data_preparation.do first to generate fdi_panel_data_clean.dta, then run 02_panel_regression.do**

---

### 📊 变量说明 / Variable Description

| 变量名 | 含义 | 单位 | 预期符号 |
|--------|------|------|----------|
| ts_ratio | 产业结构高级化指数（三产/二产） | - | 被解释变量 |
| fdi | 外商直接投资实际利用额 | 亿美元 | + (技术溢出效应) |
| pgdp | 人均GDP | 元 | + (需求升级效应) |
| human_cap | 人均受教育年限 | 年 | + (人力资本支撑) |
| gov_exp | 政府支出占GDP比重 | % | +/- (政府干预效应) |
| openness | 对外开放度（进出口/GDP） | % | + (贸易联动效应) |
| infra | 公路密度（基础设施） | 公里/百km² | + (基础设施支撑) |
| urban | 城镇化率 | % | + (集聚效应) |

---

### 📈 实证方法 / Empirical Methodology

**1. 基准模型 / Baseline Models:**

- **混合OLS (Pooled OLS):**
  ```
  ts_ratioᵢₜ = β₀ + β₁·fdiᵢₜ + β₂·Xᵢₜ + εᵢₜ
  ```

- **固定效应模型 (Fixed Effects):**
  ```
  ts_ratioᵢₜ = β₀ + β₁·fdiᵢₜ + β₂·Xᵢₜ + αᵢ + εᵢₜ
  ```

- **随机效应模型 (Random Effects):**
  ```
  ts_ratioᵢₜ = β₀ + β₁·fdiᵢₜ + β₂·Xᵢₜ + uᵢ + εᵢₜ
  ```

**2. Hausman检验 / Hausman Test:**
- 原假设：随机效应模型更有效（RE is efficient）
- 若P<0.05，拒绝原假设，选择固定效应模型

**3. 稳健性检验 / Robustness Checks:**
- 替换被解释变量（第三产业占GDP比重）
- 对数形式回归（弹性分析）
- 滞后一期FDI（缓解反向因果/内生性）
- 剔除直辖市样本
- 双向固定效应（加入时间固定效应）

**4. 异质性分析 / Heterogeneity Analysis:**
- 分东、中、西三大区域回归
- 检验FDI产业升级效应的区域差异

---

### 👤 作者 / Author

上海对外经贸大学 · 国际商务专业硕士  
Shanghai University of International Business and Economics · Master of International Business
