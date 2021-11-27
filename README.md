
# TalentReview

<!-- badges: start -->
<!-- badges: end -->

The goal of TalentReview is to provide tools to easily maintain 'cliff notes' 
on your team that can be shared between managers. This can help ensure that 
any leader is able to speak to the team, beyond their own line reports.

It also uses this data to help facilitate talent review meetings, as well as providing
visual prompts for promotions.

## Data

Data is stored in `.yaml` files. Information on each person is stored in 
one file per manager. In addition, there should be a `config.yaml` that helps 
to provide mappings (e.g. what are your job levels, and EoY ratings categories).

### People data

The package assumes you track the following information:

- Name
- userid (for extending internal data through API linkages)
- job level
- highlights (you can store more than 3, but only 3 are shown in the app)
- dev areas (you can store more than 3, but only 3 are shown in the app)
- perfomance/rating
- promotion readiness

As an example, for the manager Giacomo Nero, that manages Jimmy Black and 
Johan Schwartz, you would have file `Giacomo_Nero.yaml` with the following 
contents.

```yaml
Jimmy Black:
  userid: blackjimmy
  photo_url: https://i.pravatar.cc/150?img=49
  job_levels:
    ds: 2018-02-02
    sds: 2020-01-05
    pds: 2020-09-05
  highlights:
    - Here is some text.
    - Led first project, working with that other department.
    - Always on time, except when he's not.
  key_dev_areas:
    - Punctuality, as sleeps in a lot and misses meetings.
    - Looking to be challenged working with matrix teams, as usually internally focussed.
    - Stop dialling into meetings using selfie-camera, to prevent colleagues getting sea sickness.
  eoy_rating: Adequate
  promotion_readiness: Sept 2023

Johan Schwartz:
  userid: schwartzj
  job_levels:
    ds: 2008-02-02
  highlights:
    - Learnt to sew, then applied new skills on an amazing new jumper with knitted panaroma of sunset over Big Sur.
    - Led first project, working with that other department.
    - Always on time, except when he's not.
  key_dev_areas:
    - Punctuality, as sleeps in a lot and misses meetings.
    - Looking to be challenged working with matrix teams, as usually internally focussed.
    - Stop dialling into meetings using selfie-camera, to prevent colleagues getting sea sickness.
  eoy_rating: Superstar
  promotion_readiness: Feb 2022
```

### Config data

Job levels and how ratings are scaled seems a fluid thing, even within a single 
team over time, so there is a also a `config.yaml` file, to enable you to stay 
aligned with current guidance from HR.

### Example

An example complete setup is stored in https://github.com/epijim/TalentReview/tree/master/inst/extdata.

## Running the app

