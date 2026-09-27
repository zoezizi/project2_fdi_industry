* ==============================================================================
* 项目二：FDI对中国产业结构升级的影响研究——基于省际面板数据
* Project 2: Impact of FDI on Industrial Structure Upgrading
*         - Evidence from Chinese Provincial Panel Data
* ==============================================================================
* Step 1: 数据获取与整理 (Data Acquisition & Cleaning) — 纯Stata实现
* 纯Stata项目，不依赖Python / Pure Stata, no Python dependency
*
* 数据来源 / Data Sources:
*   - 国家统计局 (National Bureau of Statistics of China)
*   - 《中国统计年鉴》历年数据
*   - 各省份统计年鉴
* ==============================================================================

* ---- 0. 环境设置 ----
clear all
set more off
set varabbrev off
set linesize 120

capture cd "C:/Users/33841/Desktop/project2_fdi_industry"

capture log close
log using "output/data_prep_log.smcl", replace smcl

disp ""
disp "=============================================================================="
disp "  项目二：FDI对中国产业结构升级的影响研究"
disp "  Project 2: FDI and Industrial Structure Upgrading"
disp "  (基于省际面板数据 / Provincial Panel Data)"
disp "  数据准备 — 纯Stata实现 / Data Preparation — Pure Stata"
disp "=============================================================================="
disp ""
disp "当前工作目录: `c(pwd)'"
disp ""

* ---- 1. 导入原始数据 ----
disp "Step 1: 导入原始数据 / Importing raw data..."
disp ""

* 从CSV导入原始面板数据
import delimited using "data/fdi_panel_data_raw.csv", varnames(1) clear stringcols(1 3)

* 重命名变量（确保变量名为英文且规范）
disp "  数据导入成功！"
disp "  变量列表："
describe
disp ""

* 确保数据类型正确
destring fdi, replace force
destring ts_ratio, replace force
destring tertiary_share, replace force
destring secondary_share, replace force
destring pgdp, replace force
destring human_cap, replace force
destring gov_exp, replace force
destring openness, replace force
destring infra, replace force
destring urban, replace force
destring year, replace force

* 标签变量
label var province "省份名称 Province"
label var year "年份 Year"
label var region "地区分类 Region"
label var fdi "外商直接投资(亿美元) FDI"
label var ts_ratio "产业结构高级化指数 TS Ratio"
label var tertiary_share "第三产业占比(%) Tertiary Share"
label var secondary_share "第二产业占比(%) Secondary Share"
label var pgdp "人均GDP(元) GDP per capita"
label var human_cap "人力资本(年) Human Capital"
label var gov_exp "政府支出占比(%) Gov Expenditure"
label var openness "对外开放度(%) Openness"
label var infra "基础设施 Infra"
label var urban "城镇化率(%) Urbanization"

disp "  变量标签设置完成"
disp ""

* ---- 2. 数据清洗 ----
disp "=============================================================================="
disp "  Step 2: 数据清洗 / Data Cleaning"
disp "=============================================================================="
disp ""

* 检查缺失值
disp "缺失值检查 / Missing values check:"
misstable summarize fdi ts_ratio pgdp human_cap gov_exp openness infra urban
disp ""

* 删除缺失值（如有）
drop if missing(fdi, ts_ratio, pgdp, human_cap, gov_exp, openness, infra, urban)

* 检查数据维度
disp "  清洗后数据维度 / Data dimensions after cleaning:"
disp "  观测值数量 N = `=_N'"
tabulate year
disp ""

* ---- 3. 变量构造 ----
disp "=============================================================================="
disp "  Step 3: 变量构造 / Variable Construction"
disp "=============================================================================="
disp ""

* 生成对数变量（用于弹性分析）
gen ln_fdi = ln(fdi)
gen ln_ts_ratio = ln(ts_ratio)
gen ln_pgdp = ln(pgdp)
gen ln_infra = ln(infra)

label var ln_fdi "ln(FDI) 对数外商直接投资"
label var ln_ts_ratio "ln(产业结构高级化指数)"
label var ln_pgdp "ln(人均GDP)"
label var ln_infra "ln(基础设施)"

* 生成省份ID
encode province, gen(prov_id)
label var prov_id "省份ID Province ID"

* 设置面板数据结构
xtset prov_id year
disp "  面板数据结构已设置 / Panel data structure set"
xtdescribe
disp ""

* 保存清洗后的数据（DTA格式，供后续回归使用）
save "data/fdi_panel_data_clean.dta", replace
disp "  清洗后数据已保存 / Cleaned data saved: data/fdi_panel_data_clean.dta"

* 同时导出CSV（方便查看）
outsheet province year region prov_id fdi ts_ratio tertiary_share secondary_share ///
    pgdp human_cap gov_exp openness infra urban ///
    ln_fdi ln_ts_ratio ln_pgdp ln_infra ///
    using "data/fdi_panel_data_clean.csv", comma replace
disp "  CSV数据已保存 / CSV saved: data/fdi_panel_data_clean.csv"
disp ""

* ---- 4. 描述性统计 ----
disp "=============================================================================="
disp "  Step 4: 描述性统计 / Descriptive Statistics"
disp "=============================================================================="
disp ""

* 主要变量描述性统计
disp "主要变量描述性统计 / Main Variables Descriptive Statistics:"
summarize ts_ratio fdi pgdp human_cap gov_exp openness infra urban

* 输出描述性统计表（RTF格式，可用Word打开）
* 检查estout是否安装
capture which esttab
if _rc != 0 {
    disp "正在安装 estout 包..."
    ssc install estout, replace
}

estpost summarize ts_ratio fdi pgdp human_cap gov_exp openness infra urban
esttab using "output/tables/table1_descriptive_stats.rtf", ///
    cells("count mean sd min p50 max") ///
    title("表1 主要变量描述性统计") ///
    alignment(center) replace
disp "  描述性统计表已保存 / Descriptive stats table saved"
disp ""

* 分地区描述性统计
disp "分地区描述性统计 / By Region:"
tabstat ts_ratio fdi pgdp human_cap openness urban, by(region) stat(mean sd) format(%9.2f)

* 分地区统计表
estpost tabstat ts_ratio fdi pgdp human_cap gov_exp openness infra urban, by(region) statistics(mean) columns(statistics)
esttab using "output/tables/table1b_region_stats.rtf", ///
    cells("mean") ///
    title("表1b 分地区描述性统计") ///
    alignment(center) replace
disp "  分地区统计表已保存 / Region stats table saved"
disp ""

* ---- 5. 数据可视化 ----
disp "=============================================================================="
disp "  Step 5: 数据可视化 / Data Visualization"
disp "=============================================================================="
disp ""

* 图1：代表性省份产业结构高级化趋势
disp "图1：代表性省份产业结构高级化趋势"
preserve
    local selected "广东 江苏 北京 四川 河南 甘肃"
    local n : word count `selected'
    local colors "navy maroon forest_green dkorange teal cranberry"
    local i = 1

    twoway (connected ts_ratio year if province == "广东", lcolor(navy) mcolor(navy) lwidth(medthick)) ///
           (connected ts_ratio year if province == "江苏", lcolor(maroon) mcolor(maroon) lwidth(medthick)) ///
           (connected ts_ratio year if province == "北京", lcolor(forest_green) mcolor(forest_green) lwidth(medthick)) ///
           (connected ts_ratio year if province == "四川", lcolor(dkorange) mcolor(dkorange) lwidth(medthick)) ///
           (connected ts_ratio year if province == "河南", lcolor(teal) mcolor(teal) lwidth(medthick)) ///
           (connected ts_ratio year if province == "甘肃", lcolor(cranberry) mcolor(cranberry) lwidth(medthick)), ///
           title("代表性省份产业结构高级化指数趋势(2010-2022)") ///
           xtitle("年份 Year") ///
           ytitle("产业结构高级化指数(三产/二产)") ///
           legend(order(1 "广东" 2 "江苏" 3 "北京" 4 "四川" 5 "河南" 6 "甘肃") rows(2) size(small)) ///
           scheme(s1color) graphregion(color(white))
    graph export "output/figures/fig1_ts_trend.png", replace width(2000)
restore
disp "  ✅ 图1已保存 / Fig 1 saved"
disp ""

* 图2：FDI与产业结构散点图
disp "图2：FDI与产业结构散点图"
twoway (scatter ts_ratio fdi if region == "东部", mcolor(navy%50) msize(small)) ///
       (scatter ts_ratio fdi if region == "中部", mcolor(maroon%50) msize(small)) ///
       (scatter ts_ratio fdi if region == "西部", mcolor(forest_green%50) msize(small)) ///
       (lfit ts_ratio fdi, lcolor(black) lwidth(medthick) lpattern(dash)), ///
       title("FDI与产业结构高级化散点图") ///
       xtitle("FDI(亿美元)") ///
       ytitle("产业结构高级化指数") ///
       legend(order(1 "东部" 2 "中部" 3 "西部" 4 "拟合线") rows(2) size(small)) ///
       scheme(s1color) graphregion(color(white))
graph export "output/figures/fig2_fdi_ts_scatter.png", replace width(2000)
disp "  ✅ 图2已保存 / Fig 2 saved"
disp ""

* 图3：三大区域平均FDI趋势
disp "图3：三大区域平均FDI趋势"
preserve
    collapse (mean) fdi, by(year region)
    twoway (connected fdi year if region == "东部", lcolor(navy) mcolor(navy) lwidth(medthick)) ///
           (connected fdi year if region == "中部", lcolor(maroon) mcolor(maroon) lwidth(medthick)) ///
           (connected fdi year if region == "西部", lcolor(forest_green) mcolor(forest_green) lwidth(medthick)), ///
           title("三大区域FDI平均水平变化趋势(2010-2022)") ///
           xtitle("年份 Year") ///
           ytitle("平均FDI(亿美元)") ///
           legend(order(1 "东部" 2 "中部" 3 "西部") rows(1) size(small)) ///
           scheme(s1color) graphregion(color(white))
    graph export "output/figures/fig3_fdi_region_trend.png", replace width(2000)
restore
disp "  ✅ 图3已保存 / Fig 3 saved"
disp ""

* 图4：全国平均FDI与产业结构双轴图
disp "图4：全国平均FDI与产业结构双轴图"
preserve
    collapse (mean) fdi ts_ratio, by(year)
    twoway (bar fdi year, barwidth(0.6) color(navy%60) yaxis(1)) ///
           (connected ts_ratio year, lcolor(cranberry) mcolor(cranberry) lwidth(medthick) yaxis(2)), ///
           title("全国平均FDI与产业结构高级化指数变化") ///
           xtitle("年份 Year") ///
           ytitle("平均FDI(亿美元)", axis(1) color(navy)) ///
           ytitle("产业结构高级化指数", axis(2) color(cranberry)) ///
           legend(order(1 "FDI(左轴)" 2 "产业结构指数(右轴)") rows(1) size(small)) ///
           scheme(s1color) graphregion(color(white))
    graph export "output/figures/fig4_fdi_ts_dual.png", replace width(2000)
restore
disp "  ✅ 图4已保存 / Fig 4 saved"
disp ""

* 图5：第三产业占比地区分布箱线图
disp "图5：第三产业占比地区分布箱线图"
graph box tertiary_share, over(region) ///
    title("三大区域第三产业占GDP比重分布") ///
    ytitle("第三产业占比(%)") ///
    scheme(s1color) graphregion(color(white))
graph export "output/figures/fig5_tertiary_boxplot.png", replace width(2000)
disp "  ✅ 图5已保存 / Fig 5 saved"
disp ""

* ---- 6. 结果汇总 ----
disp "=============================================================================="
disp "  🎉 数据准备与可视化完成！纯Stata实现"
disp "  Data preparation & visualization completed! Pure Stata"
disp "=============================================================================="
disp ""
disp "📁 输出文件清单 / Output Files:"
disp ""
disp "  数据文件 / Data:"
disp "    - data/fdi_panel_data_raw.csv       原始面板数据"
disp "    - data/fdi_panel_data_clean.dta     清洗后数据(Stata格式)"
disp "    - data/fdi_panel_data_clean.csv     清洗后数据(CSV格式)"
disp ""
disp "  表格 / Tables:"
disp "    - output/tables/table1_descriptive_stats.rtf   描述性统计"
disp "    - output/tables/table1b_region_stats.rtf       分地区统计"
disp ""
disp "  图表 / Figures:"
disp "    - output/figures/fig1_ts_trend.png         产业结构趋势图"
disp "    - output/figures/fig2_fdi_ts_scatter.png   FDI散点图"
disp "    - output/figures/fig3_fdi_region_trend.png 分地区FDI趋势"
disp "    - output/figures/fig4_fdi_ts_dual.png      FDI与产业结构双轴图"
disp "    - output/figures/fig5_tertiary_boxplot.png 三产占比箱线图"
disp ""
disp "🚀 下一步：运行 02_panel_regression.do 进行面板回归分析"
disp "   Next step: Run 02_panel_regression.do for panel regression"
disp ""

log close
