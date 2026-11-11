# Inputs are acquired, not bundled

`run_all.R` downloads the fixed Zenodo release in `config/source.csv` over HTTPS and checks the archive-supplied MD5 before analysis. MD5 identifies this exact archive payload; it is not a cryptographic authenticity guarantee. A mismatch stops execution and preserves an existing local input for investigation.

Zhao, Yuquan (2026). *Processed quarterly water-quality dataset for dissolved organic carbon variance attribution in Tokyo Bay, 1981-2021*. [Zenodo, DOI 10.5281/zenodo.21798408](https://doi.org/10.5281/zenodo.21798408). License: [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

This repository neither redistributes nor writes to the doctoral raw-monitoring directory. Store any restricted local station exports outside this folder or under ignored `data/private/`. Never commit them. The public workbook is also ignored to keep its archival DOI as the controlling source.
