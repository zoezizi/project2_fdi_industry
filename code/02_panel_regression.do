* ==============================================================================
* 项目二：FDI对中国产业结构升级的影响研究——基于省际面板数据
* Project 2: Impact of FDI on Industrial Structure Upgrading
*         - Evidence from Chinese Provincial Panel Data
* ==============================================================================
* 研究方法：面板数据模型（混合OLS、固定效应、随机效应）、Hausman检验、
*          稳健性检验、异质性分析
* Methodology: Panel Data Models (Pooled OLS, FE, RE), Hausman Test,
*              Robustness Checks, Heterogeneity Analysis
* 数据来源：国家统计局、各省份统计年鉴
* Data Source: NBS of China, Provincial Statistical Yearbooks
* ==============================================================================

* ---- 0. 环境设置 ----
clear all
set more off
set varabbrev off
set linesize 120

capture cd "C:/Users/33841/Desktop/project2_fdi_industry"

capture log close
log using "output/stata_log.smcl", replace smcl

disp ""
disp "=============================================================================="
disp "  项目二：FDI对中国产业结构升级的影响研究"
disp "  Project 2: FDI and Industrial Structure Upgrading"
disp "  (基于省际面板数据 / Provincial Panel Data)"
disp "=============================================================================="
disp ""
disp "当前工作目录: `c(pwd)'"
disp ""

* 检查estout
capture which esttab
if _rc != 0 {
    disp "正在安装 estout 包..."
    ssc install estout, replace
}

* ---- 1. 导入数据与面板设置 ----
disp "Step 1: 导入清洗后数据（由01_data_preparation.do生成）"
disp ""

* 使用Stata格式数据（由01_data_preparation.do生成）
use "data/fdi_panel_data_clean.dta", clear

* 面板数据结构已在01_data_preparation.do中设置，此处确认
xtset prov_id year

disp "  面板数据设置完成！"
xtdescribe
disp ""

* ---- 2. 描述性统计 ----
disp "=============================================================================="
disp "  Step 2: 描述性统计 / Descriptive Statistics"
disp "=============================================================================="
disp ""

summarize ts_ratio fdi pgdp human_cap gov_exp openness infra urban

estpost summarize ts_ratio fdi pgdp human_cap gov_exp openness infra urban
esttab using "output/tables/table1_descriptive_stats.rtf", ///
    cells("count mean sd min p50 max") ///
    title("表1 主要变量描述性统计") ///
    alignment(center) replace

disp "  描述性统计表已保存"
disp ""

* ---- 3. 基准回归 ----
disp "=============================================================================="
disp "  Step 3: 基准回归 / Baseline Regression"
disp "=============================================================================="
disp ""

* 模型1：混合OLS (Pooled OLS)
disp "模型1：混合OLS (Pooled OLS)"
reg ts_ratio fdi pgdp human_cap gov_exp openness infra urban
estimates store pool

* 模型2：固定效应 (Fixed Effects)
disp ""
disp "模型2：固定效应模型 (Fixed Effects Model)"
xtreg ts_ratio fdi pgdp human_cap gov_exp openness infra urban, fe
estimates store fe

* 模型3：随机效应 (Random Effects)
disp ""
disp "模型3：随机效应模型 (Random Effects Model)"
xtreg ts_ratio fdi pgdp human_cap gov_exp openness infra urban, re
estimates store re

* 输出基准回归结果表
esttab pool fe re using "output/tables/table2_baseline_regression.rtf", ///
    se star(* 0.1 ** 0.05 *** 0.01) ///
    title("表2 FDI对产业结构升级影响的基准回归结果") ///
    mtitle("混合OLS" "固定效应" "随机效应") ///
    stats(r2 r2_a N, labels("R-squared" "Adj R-squared" "Observations")) ///
    alignment(center) replace

disp ""
disp "  基准回归结果表已保存"
disp ""

* ---- 4. Hausman检验 ----
disp "=============================================================================="
disp "  Step 4: Hausman检验 / Hausman Test"
disp "=============================================================================="
disp ""

disp "原假设 H0: 随机效应模型更有效 (Random effects model is efficient)"
disp "备择假设 H1: 固定效应模型更一致 (Fixed effects model is consistent)"
disp ""

quietly xtreg ts_ratio fdi pgdp human_cap gov_exp openness infra urban, fe
estimates store fe_test
quietly xtreg ts_ratio fdi pgdp human_cap gov_exp openness infra urban, re
estimates store re_test

hausman fe_test re_test

* 保存检验统计量
local chi2_val = r(chi2)
local p_val = r(p)
local df_val = r(df)

disp ""
disp "  检验结论："
if `p_val' < 0.05 {
    disp "  Prob > chi2 = `p_val' < 0.05，拒绝原假设，应选择固定效应模型"
    disp "  Reject H0, choose Fixed Effects model"
}
else {
    disp "  Prob > chi2 = `p_val' > 0.05，不能拒绝原假设，选择随机效应模型"
    disp "  Cannot reject H0, choose Random Effects model"
}

* 用esttab输出FE和RE对比表（附带Hausman检验信息在标题中）
esttab fe_test re_test using "output/tables/table3_hausman_test.rtf", ///
    se star(* 0.1 ** 0.05 *** 0.01) ///
    title("表3 Hausman检验：固定效应 vs 随机效应 (chi2(`df_val')=`chi2_val', p=`p_val')") ///
    mtitle("固定效应 FE" "随机效应 RE") ///
    stats(r2 r2_a N, labels("R-squared" "Adj R-squared" "Observations")) ///
    alignment(center) replace

disp "  Hausman检验结果表已保存"
disp ""

* ---- 5. 稳健性检验 ----
disp "=============================================================================="
disp "  Step 5: 稳健性检验 / Robustness Checks"
disp "=============================================================================="
disp ""

* 以固定效应为基准（通常FE更可靠）

* 稳健性检验1：替换被解释变量（用第三产业占比）
disp "稳健性检验1：替换被解释变量 (Tertiary Industry Share)"
xtreg tertiary_share fdi pgdp human_cap gov_exp openness infra urban, fe
estimates store rob1

* 稳健性检验2：对数形式（弹性分析）
disp ""
disp "稳健性检验2：对数形式模型 (Log Form / Elasticity)"
xtreg ln_ts_ratio ln_fdi ln_pgdp human_cap gov_exp openness ln_infra urban, fe
estimates store rob2

* 稳健性检验3：滞后一期FDI（缓解内生性/反向因果）
disp ""
disp "稳健性检验3：滞后一期FDI (Lagged FDI)"
xtreg ts_ratio L.fdi pgdp human_cap gov_exp openness infra urban, fe
estimates store rob3

* 稳健性检验4：剔除直辖市（北京、天津、上海、重庆）
disp ""
disp "稳健性检验4：剔除直辖市 (Excluding Municipalities)"
xtreg ts_ratio fdi pgdp human_cap gov_exp openness infra urban if ///
    province != "北京" & province != "天津" & province != "上海" & province != "重庆", fe
estimates store rob4

* 稳健性检验5：加入时间固定效应
disp ""
disp "稳健性检验5：双向固定效应 (Two-way FE: 个体+时间)"
xtreg ts_ratio fdi pgdp human_cap gov_exp openness infra urban i.year, fe
estimates store rob5

* 输出稳健性检验结果表
esttab rob1 rob2 rob3 rob4 rob5 using "output/tables/table4_robustness_check.rtf", ///
    se star(* 0.1 ** 0.05 *** 0.01) ///
    title("表4 稳健性检验结果") ///
    mtitle("替换被解释变量" "对数形式" "滞后FDI" "剔除直辖市" "双向固定效应") ///
    stats(r2 r2_a N, labels("R-squared" "Adj R-squared" "Observations")) ///
    alignment(center) replace

disp ""
disp "  稳健性检验结果表已保存"
disp ""

* ---- 6. 异质性分析（分地区） ----
disp "=============================================================================="
disp "  Step 6: 异质性分析 / Heterogeneity Analysis (By Region)"
disp "=============================================================================="
disp ""

* 东部地区
disp "异质性分析：东部地区 / Eastern Region"
xtreg ts_ratio fdi pgdp human_cap gov_exp openness infra urban if region == "东部", fe
estimates store east

* 中部地区
disp ""
disp "异质性分析：中部地区 / Central Region"
xtreg ts_ratio fdi pgdp human_cap gov_exp openness infra urban if region == "中部", fe
estimates store central

* 西部地区
disp ""
disp "异质性分析：西部地区 / Western Region"
xtreg ts_ratio fdi pgdp human_cap gov_exp openness infra urban if region == "西部", fe
estimates store west

* 输出分地区回归结果
esttab east central west using "output/tables/table5_heterogeneity.rtf", ///
    se star(* 0.1 ** 0.05 *** 0.01) ///
    title("表5 分地区异质性分析结果（固定效应）") ///
    mtitle("东部地区" "中部地区" "西部地区") ///
    stats(r2 r2_a N, labels("R-squared" "Adj R-squared" "Observations")) ///
    alignment(center) replace

disp ""
disp "  异质性分析结果表已保存"
disp ""

* ---- 7. 模型诊断 ----
disp "=============================================================================="
disp "  Step 7: 模型诊断 / Model Diagnostics"
disp "=============================================================================="
disp ""

quietly xtreg ts_ratio fdi pgdp human_cap gov_exp openness infra urban, fe

* 多重共线性检验
disp "多重共线性检验 / VIF Test (after reg):"
reg ts_ratio fdi pgdp human_cap gov_exp openness infra urban
estat vif

disp ""

* ---- 8. 数据导出 ----
quietly xtreg ts_ratio fdi pgdp human_cap gov_exp openness infra urban, fe
predict fitted_fe, xb
predict resid_fe, e

outsheet province year ts_ratio fdi fitted_fe resid_fe region ///
    using "data/fdi_regression_results.csv", comma replace

disp "  回归结果数据已保存：data/fdi_regression_results.csv"
disp ""

* ---- 9. 结果汇总 ----
disp "=============================================================================="
disp "  🎉 面板数据实证分析完成！"
disp "  Panel Data Empirical Analysis Completed!"
disp "=============================================================================="
disp ""
disp "📊 输出文件清单 / Output Files:"
disp ""
disp "  表格 / Tables:"
disp "    - output/tables/table1_descriptive_stats.rtf    描述性统计"
disp "    - output/tables/table2_baseline_regression.rtf  基准回归（OLS/FE/RE）"
disp "    - output/tables/table3_hausman_test.rtf         Hausman检验"
disp "    - output/tables/table4_robustness_check.rtf     稳健性检验（5种）"
disp "    - output/tables/table5_heterogeneity.rtf        分地区异质性分析"
disp ""
disp "  数据 / Data:"
disp "    - data/fdi_panel_data_clean.csv                 清洗后面板数据"
disp "    - data/fdi_regression_results.csv               回归结果数据"
disp ""
disp "💡 提示：.rtf文件可直接用Word打开，复制粘贴到论文中即可"
disp ""

log close
