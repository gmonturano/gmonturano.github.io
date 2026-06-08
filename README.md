# Gianluca Monturano — Academic Website

Personal academic website of **Gianluca Monturano**, quantitative economist and data scientist.

The website is built as a static GitHub Pages site using plain HTML, CSS and JavaScript. It presents academic roles, research outputs, teaching activity, software material, dissemination events and the full curriculum vitae.

## Website structure

The repository contains the main pages of the academic website:

```text
index.html             Home page and academic presentation
research.html          Publications, submitted papers, projects, grants and service
software.html          Code, statistical workflows and software material
teaching.html          Teaching, lectures and invited seminars
dissemination.html     Conferences, workshops and dissemination map
cv.html                Academic CV page with embedded PDF
styles.css             Main stylesheet
script.js              JavaScript utilities
assets/                Images, icons and static files
cv/                    LaTeX CV source and generated PDF
```

## Home page

The home page contains a concise academic presentation with:

```text
profile photo
academic and professional profile icons
institutional email contacts
current roles
research profile
main programming tools
```

The profile icons use local files stored in:

```text
assets/icons/
```

The profile photo is stored in:

```text
assets/rofile-photo.sv.jpg
```

## Research page

The research page includes:

```text
peer-reviewed articles
submitted and ongoing papers
book chapters
working papers
grants and awards
research projects
formal research appointments
conference organization and organized sessions
editorial activity
scientific dissemination
review activity
```

Journal names for published and ongoing papers are styled separately from paper titles. Project and dissemination links are embedded directly in the text.

## Teaching page

The teaching page reports:

```text
PhD teaching
undergraduate and graduate courses
tutoring activities
teaching assistance and tutorials
lectures and invited speaking
```

The page uses a wider text layout with a sticky index for easier navigation.

## Dissemination page

The dissemination page presents conferences, seminars and workshops through:

```text
interactive map
year filter
type filter
event list
summary statistics
```

The map uses a satellite basemap with place labels and highlights academic dissemination activities by location and type.

## Software page

The software page documents research-related technical material, including:

```text
GitHub repositories
R routines for statistical analysis
Python workflows for data science
LaTeX templates
Markdown and Quarto material
replication code and reproducible workflows
```

GitHub is presented as the central hub for code, replication material, templates and research workflows.

## CV page

The CV page contains:

```text
current roles
previous roles and education
other academic roles
academic profiles
embedded full CV PDF
```

The full CV is generated from the LaTeX source stored in:

```text
cv/
```

The generated PDF is expected at:

```text
cv/main.pdf
```

and is embedded directly in `cv.html`.

## Icons

Academic and professional icons are stored locally in:

```text
assets/icons/
```

The website uses local icon files for:

```text
LinkedIn
Microsoft Teams
Google Scholar
GitHub
ResearchGate
ORCID
Scopus
X
arXiv
SSRN
R
Python
LaTeX
Markdown
Quarto
```

Using local icons avoids external dependencies and keeps the website stable on GitHub Pages.

## CV generation

The CV is written in LaTeX and stored in the `cv/` folder.

A GitHub Actions workflow can compile the LaTeX source and generate:

```text
cv/main.pdf
```

The PDF is then shown directly on the CV page through an embedded viewer.

## GitHub Pages deployment

To publish the website:

1. Open the repository on GitHub.
2. Go to **Settings**.
3. Open **Pages**.
4. Select **Deploy from branch**.
5. Choose branch `main`.
6. Choose folder `/root`.
7. Save.

The website will be available through GitHub Pages after the deployment finishes.

## Updating the website

To update the site:

```text
edit the relevant HTML file
commit the change
wait for GitHub Pages deployment
refresh the website
```

For visual changes, edit:

```text
styles.css
```

For profile icons or images, update files in:

```text
assets/icons/
assets/
```

For the full CV, update the LaTeX source in:

```text
cv/
```

and let the workflow regenerate the PDF.

## Notes

This repository is designed for a clean academic website with a quantitative-economics style: minimal layout, local assets, reproducible CV generation, and separate pages for research, teaching, software, dissemination and curriculum vitae.
