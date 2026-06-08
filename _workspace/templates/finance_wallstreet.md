<div class="foundry-finance-report">
  <div class="header-section">
    <h1 class="report-title">{{REPORT_TITLE}}</h1>
    <div class="meta-info">
      <span class="ticker">{{TICKER_SYMBOL}}</span> | <span class="date">{{DATE}}</span>
      <span class="analyst">{{ANALYST_NAME}}</span>
    </div>
  </div>

  <div class="executive-summary">
    <h2>Executive Summary</h2>
    <div class="rating-box">
      <span class="rating-badge {{RATING_CLASS}}">{{RATING}}</span> <!-- e.g., BUY, HOLD, SELL -->
      <span class="target-price">Target Price: {{TARGET_PRICE}}</span>
    </div>
    <p class="summary-text">{{SUMMARY_TEXT}}</p>
  </div>

  <div class="investment-thesis">
    <h2>Investment Thesis</h2>
    <ul>
      {{#each THESIS_POINTS}}
      <li>{{this}}</li>
      {{/each}}
    </ul>
  </div>

  <div class="financial-data-grid">
    <h2>Key Financials & Valuation</h2>
    <table class="foundry-data-table">
      <thead>
        <tr>
          <th>Metric</th>
          <th>{{YEAR_1}}</th>
          <th>{{YEAR_2}}</th>
          <th>{{YEAR_3_PROJ}}</th>
        </tr>
      </thead>
      <tbody>
        {{#each FINANCIAL_ROWS}}
        <tr>
          <td>{{this.metric_name}}</td>
          <td>{{this.year_1_val}}</td>
          <td>{{this.year_2_val}}</td>
          <td>{{this.year_3_val}}</td>
        </tr>
        {{/each}}
      </tbody>
    </table>
  </div>

  <div class="risk-factors">
    <h2>Risk Factors</h2>
    <div class="alert-box risk-alert">
      {{RISK_FACTORS_TEXT}}
    </div>
  </div>
</div>
