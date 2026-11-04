{% macro image() %}
#pad(left: {{ design.header.photo_space_left }}, right: {{ design.header.photo_space_right }}, image("{{ cv.photo.name }}", width: {{ design.header.photo_width }}))
{% endmacro %}

{% if cv.photo %}
{% set photo = "image(\"" + cv.photo|string + "\", width: "+ design.header.photo_width + ")" %}
#grid(
{% if design.header.photo_position == "left" %}
  columns: (auto, 1fr),
{% else %}
  columns: (1fr, auto),
{% endif %}
  column-gutter: 0cm,
  align: horizon + left,
{% if design.header.photo_position == "left" %}
  [{{ image() }}],
  [
{% else %}
  [
{% endif %}
{% endif %}
{% if cv.name %}
= {{ cv.name }}

// A thin rule spanning the content width, between the name and contact details.
#block(width: 100%, above: 0pt, below: 6pt)[
  #line(length: 100%, stroke: 0.6pt)
]
{% endif %}

{% if cv.headline %}
  #headline([{{ cv.headline }}])

{% endif %}
#{
  // Override link rendering only within the contact header. Leave RenderCV's
  // escaped content, icons, ordering, and generated connection markup intact.
  let rendercv-link = link
  let link(destination, body, ..options) = {
    if type(destination) == str and destination.starts-with("mailto:") {
      body
    } else {
      let options = options.named()
      options.insert("if-color", true)
      rendercv-link(destination, strong(body), ..options)
    }
  }
  connections(
{% for connection in cv._connections %}
    [{{ connection }}],
{% endfor %}
  )
}
{% if cv.photo %}
{% if design.header.photo_position == "left" %}
  ]
)
{% else %}
  ],
  [{{ image() }}],
)
{% endif %}
{% endif %}
