# Inline-SVG Extension For Quarto

This filter is configured to run on any HTML or Markdown conversions. When an image is encountered during the conversion, if it is referencing a local SVG (e.g. one that has been generated during the build process), it will read the contents of the SVG and inject them into the resulting file

Here are the contents of `example.qmd`, a Quarto file where we render a plot using SVG:

````markdown
---
title: "Inline-SVG Example"
fig-format: svg
filters:
  - inline-svg
---

```{r}
plot(mtcars)
```
````

If you render this to `commonmark` normally, the output would be

```markdown
![](example_files/figure-commonmark/unnamed-chunk-1-1.svg)
```

But with this filter applied, you get the SVG in-line instead of referenced:

```markdown
<svg>...</svg>
```

## Accessibility

If we just replaced the image markdown (or markup) with the SVG tag, any accessibility components built in to the `<img>` would be removed as they are not included in the SVG as part of the render process. This filter handles this by

- adding `role=img` to the `<svg>`
- transferring any `<img title>` to a nested `<title>` within the `<svg>` and including an `aria-labelledby` pointing to the `<title>`
- transferring any `<img alt>` to a nested `<desc>` within the `<svg>` and including an `aria-describedby` pointing to the `<desc>`

When a `title` or `alt` text are not found on the image tag, default values are used. In the case of the above example,

```markdown
![](example_files/figure-commonmark/unnamed-chunk-1-1.svg)
```

will yield

```markdown
<svg aria-labelledby="unnamed-chunk-1-1--title" aria-describedby="unnamed-chunk-1-1--desc">
  <title id="unnamed-chunk-1-1--title">Untitled figure</title>
  <desc id="unnamed-chunk-1-1--desc">No description</desc>
  ...
</svg>
```

We try to stay on top of accessibility updates, so if you have suggestions or improvements, please don't hestitate to submit an issue or pull request!

## Installing

```shell
quarto install extension coursekata/quarto-inline-svg
```

This will install the extension under the `_extensions` subdirectory.
If you're using version control, you will want to check in this directory.

## Using

Set the figure format to SVG and then include the extension in your filter configuration:

```yaml
fig-format: svg
filters:
  - inline-svg
```

## Example

Here is the source code for a minimal example: [example.qmd](example.qmd). Try running `quarto render --to commonmark example.qmd`.
