Tests and Coverage
================
28 November, 2021 09:48:43

-   [Coverage](#coverage)
-   [Unit Tests](#unit-tests)

This output is created by
[covrpage](https://github.com/yonicd/covrpage).

## Coverage

Coverage summary is created using the
[covr](https://github.com/r-lib/covr) package.

    ## ⚠️ Not All Tests Passed
    ##   Coverage statistics are approximations of the non-failing tests.
    ##   Use with caution
    ## 
    ##  For further investigation check in testthat summary tables.

| Object                                              | Coverage (%) |
|:----------------------------------------------------|:------------:|
| TalentReview                                        |     9.39     |
| [R/golem_utils_server.R](../R/golem_utils_server.R) |     0.00     |
| [R/golem_utils_ui.R](../R/golem_utils_ui.R)         |     0.00     |
| [R/run_app.R](../R/run_app.R)                       |     0.00     |
| [R/app_config.R](../R/app_config.R)                 |    14.29     |
| [R/app_ui.R](../R/app_ui.R)                         |    100.00    |

<br>

## Unit Tests

Unit Test summary is created using the
[testthat](https://github.com/r-lib/testthat) package.

| file                                                          |   n |  time | error | failed | skipped | warning | icon |
|:--------------------------------------------------------------|----:|------:|------:|-------:|--------:|--------:|:-----|
| [test-app.R](testthat/test-app.R)                             |   1 | 0.036 |     0 |      0 |       0 |       0 |      |
| [test-golem-recommended.R](testthat/test-golem-recommended.R) |   1 | 0.382 |     2 |      0 |       1 |       0 | 🔶   |

<details open>
<summary>
Show Detailed Test Results
</summary>

| file                                                              | context           | test                 | status  |   n |  time | icon |
|:------------------------------------------------------------------|:------------------|:---------------------|:--------|----:|------:|:-----|
| [test-app.R](testthat/test-app.R#L2)                              | app               | multiplication works | PASS    |   1 | 0.036 |      |
| [test-golem-recommended.R](testthat/test-golem-recommended.R#L2)  | golem-recommended | app ui               | ERROR   |   0 | 0.091 |      |
| [test-golem-recommended.R](testthat/test-golem-recommended.R#L12) | golem-recommended | app server           | ERROR   |   0 | 0.085 |      |
| [test-golem-recommended.R](testthat/test-golem-recommended.R#L24) | golem-recommended | app launches         | SKIPPED |   1 | 0.206 | 🔶   |

| Failed | Warning | Skipped |
|:-------|:--------|:--------|
| 🛑     | ⚠️      | 🔶      |

</details>
<details>
<summary>
Session Info
</summary>

| Field    | Value                            |
|:---------|:---------------------------------|
| Version  | R version 4.1.0 (2021-05-18)     |
| Platform | x86_64-apple-darwin17.0 (64-bit) |
| Running  | macOS Big Sur 10.16              |
| Language | en_US                            |
| Timezone | Europe/Zurich                    |

| Package  | Version    |
|:---------|:-----------|
| testthat | 3.1.0      |
| covr     | 3.5.1.9003 |
| covrpage | 0.1        |

</details>
<!--- Final Status : error/failed --->
