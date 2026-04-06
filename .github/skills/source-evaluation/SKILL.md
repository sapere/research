---
name: source-evaluation
description: Evaluate the credibility, relevance, and reliability of a web source for research purposes. Apply source quality hierarchy, detect paywalls, assess publication date freshness, and flag potential bias.
user-invocable: false
disable-model-invocation: false
---

# Source Evaluation Skill

Use this skill when assessing whether a web source is suitable for inclusion in research synthesis. Apply every step sequentially for each source under consideration.

## Procedure

1. **Check Domain Authority**
   - Rank by authority tier: `.gov` > `.edu` > `.org` > established news outlets > industry publications > personal blogs > forums > social media
   - Government and academic sources are considered HIGH authority by default
   - Sources from recognized industry analysts (Gartner, Forrester, McKinsey) rank as HIGH for their domain
   - Anonymous or unattributed sources rank as LOW regardless of domain

2. **Check Publication Date**
   - Prefer sources published within the last 2 years for current-state research
   - Historical research may use older sources — note the publication date explicitly
   - If no publication date is visible, mark `[DATE_UNKNOWN]` and reduce reliability rating
   - Undated sources are acceptable only if corroborated by a dated source

3. **Check Author Credentials**
   - Named authors with verifiable institutional affiliations are preferred
   - Check for author bios, LinkedIn profiles, or institutional pages if credentials are unclear
   - Anonymous or pseudonymous authorship reduces reliability — flag as `[ANONYMOUS_AUTHOR]`
   - Press releases and official statements are acceptable without named authors if from recognized organizations

4. **Detect Paywalls and Access Restrictions**
   - If content is truncated, login-gated, or requires payment, mark `[PAYWALLED]`
   - Attempt fallback: check `web.archive.org` for a cached version
   - If the Wayback Machine has a copy, cite the archive URL instead
   - If no accessible version exists, do NOT cite — log as `[SOURCE_INACCESSIBLE]`

5. **Assess Bias Indicators**
   - Check for sponsored content labels, advertorial disclosures, or "paid partnership" markers
   - Check if the source is a think-tank or advocacy organization — note funding sources if disclosed
   - Political or ideological framing should be flagged: `[POTENTIAL_BIAS: reason]`
   - Industry-funded research should be noted but not automatically excluded

6. **Verify URL Accessibility**
   - Fetch the URL and confirm it returns HTTP 200
   - If the URL redirects to a different page, verify the final destination is relevant
   - If the URL returns 404, 403, or 500, mark `[URL_INACCESSIBLE: HTTP {status}]`
   - Never cite a URL you have not successfully fetched in the current session

7. **Assign Quality Rating**
   - **HIGH**: Primary/governmental/academic sources, named authors, recent, accessible, no bias indicators
   - **MEDIUM**: Established industry publications, news outlets, dated but relevant, minor caveats
   - **LOW**: Blogs, forums, social media, anonymous authors, undated, biased, or partially accessible
   - Record the rating in `research_sources.md` alongside the source entry
