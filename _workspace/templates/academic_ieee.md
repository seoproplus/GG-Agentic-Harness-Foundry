<div class="foundry-academic-paper">
  <header class="paper-header">
    <h1 class="paper-title">{{PAPER_TITLE}}</h1>
    <p class="authors">{{AUTHORS_LIST}}</p>
    <p class="affiliations">{{AFFILIATIONS_LIST}}</p>
  </header>

  <div class="abstract-section">
    <h2>Abstract</h2>
    <p class="abstract-content">
      <em>{{ABSTRACT_TEXT}}</em>
    </p>
    <p class="keywords"><strong>Keywords:</strong> {{KEYWORDS_LIST}}</p>
  </div>

  <div class="paper-body two-column-layout">
    <section class="introduction">
      <h2>I. Introduction</h2>
      <p>{{INTRODUCTION_TEXT}}</p>
    </section>

    <section class="methodology">
      <h2>II. Methodology</h2>
      <p>{{METHODOLOGY_TEXT}}</p>
      {{#if ARCHITECTURE_DIAGRAM}}
      <div class="diagram-container">
        {{ARCHITECTURE_DIAGRAM}}
        <p class="caption">Fig. 1. {{DIAGRAM_CAPTION}}</p>
      </div>
      {{/if}}
    </section>

    <section class="results">
      <h2>III. Results</h2>
      <p>{{RESULTS_TEXT}}</p>
      <table class="academic-table">
        <caption>Table I. {{TABLE_CAPTION}}</caption>
        <thead>
          {{TABLE_HEADER}}
        </thead>
        <tbody>
          {{TABLE_BODY}}
        </tbody>
      </table>
    </section>

    <section class="conclusion">
      <h2>IV. Conclusion</h2>
      <p>{{CONCLUSION_TEXT}}</p>
    </section>
  </div>

  <footer class="references-section">
    <h2>References</h2>
    <ol class="reference-list">
      {{#each REFERENCES}}
      <li>{{this}}</li>
      {{/each}}
    </ol>
  </footer>
</div>
