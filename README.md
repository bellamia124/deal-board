# Deal Board

The shared call board for the ZenaTech buy-side mandate — Transworld Business
Advisors of Florida.

One page, three callers, live. Assignment, call check-off, follow-up dates and
a per-company history that everyone sees the moment it happens.

---

## How it is put together

Two halves, deliberately separated.

**This repository holds the application.** HTML, CSS and JavaScript. It can be
public without risk, because there is not one firm name in it.

**Supabase holds the data.** Every prospect record, every assignment, every
call note. Nothing in it is readable without signing in as one of the three
invited addresses. This is the part that must never move into the repo.

That split is the whole design. GitHub Pages on a free account is public to
the internet and indexed by search engines. The list is 961 named owners,
their direct numbers, and a sentence on each explaining why they are
vulnerable to an approach. That cannot sit on a public URL.

---

## Setting it up

About twenty minutes, once.

### 1. Create the Supabase project

1. Sign up at supabase.com and create a project. The free tier is enough —
   this list is under 1,000 rows.
2. Pick a region near Florida (`us-east-1`).
3. Save the database password somewhere safe. You will not need it again for
   this, but you cannot recover it.

### 2. Build the tables

Open **SQL Editor** in the Supabase dashboard, paste the whole of
`setup/schema.sql`, and run it.

Before you run it, change the last three lines — the `insert into team` block —
to the real email addresses for you, Tim and Matt. Those addresses are the only
ones that will ever be able to sign in. Getting them wrong is the single most
common setup mistake.

### 3. Load the list

**Table Editor → firms → Insert → Import data from CSV**, and upload
`setup/firms_seed.csv` (961 firms).

Then the same for `setup/work_seed.csv` into `work`, and
`setup/activity_seed.csv` into `activity`. Those two carry the sixteen
assignments already made on 2 September, so nothing is lost.

### 4. Turn on email sign-in

**Authentication → Providers → Email.** Turn on "Enable Email provider" and
turn OFF "Confirm email" (the magic link is the confirmation).

**Authentication → URL Configuration.** Set the Site URL to the address the
board will live at — `https://<your-github-username>.github.io/deal-board/` —
and add the same address under Redirect URLs. Sign-in links break silently if
this is wrong.

### 5. Point the page at the project

**Project Settings → API.** Copy the Project URL and the `anon` `public` key
into `public/config.js`.

The anon key is safe to publish. It grants nothing by itself; every table is
behind row-level security requiring a signed-in team address. The
`service_role` key is the opposite — it bypasses everything. It never goes in
this repo, never in a browser, never in a message.

### 6. Publish

```bash
git add -A
git commit -m "Deal Board"
git push
```

Then **Settings → Pages** on the repository: Source `main`, folder `/public`.
The URL appears in a minute or two. Send it to Tim and Matt.

---

## Working it, day to day

The page opens on **Everything**, grouped by state, ranked within each state.

- **Unclaimed** is the pool. Claim before you dial — claiming afterwards is
  how two people end up on the same owner.
- Any status button also claims the card, so if you are dialling straight
  down the list you never touch the dropdown.
- **Due** is your follow-ups that have come round. Work these before the pool.
- **Mine** is your own book.
- **Worked** is everything the desk has touched — the management view.

Every change appears on the other two screens within a second or so. No
refreshing.

**Give every call a next date, even a no.** "Not for sale" today is a callback
in nine months. A blank date is a lead thrown away.

---

## Keeping the list fresh

The Mac pipeline finds new names every weekday morning. To push them:

```bash
export SUPABASE_URL="https://xxxx.supabase.co"
export SUPABASE_SERVICE_KEY="eyJ..."          # service_role key
python3 setup/push_to_supabase.py setup/firms_seed.csv
```

It updates the `firms` table only. Assignments, statuses, follow-ups and
history live in separate tables and are never touched, so a refresh cannot
erase anyone's work.

To run it automatically each morning, add those two lines and the command to
the end of the daily job in `~/zena-sourcing`.

---

## What this does not do

- **It does not know what the Mac knows.** A firm marked "Do not call" here is
  still scored and ranked by tomorrow's pipeline. That wastes a ranking slot;
  it does not produce a wrong number. Wiring the dispositions back into the
  scoring is a later job, worth doing once there are a few weeks of real calls.
- **It is not the brokerage's system of record.** The moment an owner is
  genuinely interested, that name belongs wherever Transworld tracks live
  deals — commissions, compliance and the file all live there.
- **There is no support desk.** This is a system you own. Supabase's free tier
  pauses a project after a week of no activity; it wakes on the next visit, but
  a paid tier removes that if it becomes irritating.

---

## Rules that do not change

- **No automated calling. Ever.** No ringless voicemail, no AI or recorded
  voice, no cold texts. You dial, you talk, you leave the message yourself.
- **Do not quote the revenue estimates.** Where a figure came from Apollo it is
  a model output, not a filing. The headcount is real; the revenue is a
  conversation starter.
- **Announce recording on every call.** Florida is an all-party consent state
  and you are calling from Florida. Both states, no exceptions.
- **Every number is an office switchboard** unless the card says otherwise.
- **No Arizona calls** until the A.R.S. § 32-2163 cooperation agreement with an
  Arizona-licensed broker is signed. See section 3 of the call script.
