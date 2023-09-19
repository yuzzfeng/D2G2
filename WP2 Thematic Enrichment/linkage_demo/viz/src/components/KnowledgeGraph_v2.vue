<template>
  <div>
    <svg></svg>
  </div>
</template>
<script>
import * as d3 from "d3";
import { triplesToGraph } from "@/components/functions/triplesToGraph";

export default {
  mounted() {
    const width = 800;
    const height = 500;
    const triples = [
      {
        subject: "<linkage/1615>",
        predicate: "a",
        object: "Association_CityGML_OSM",
      },
      {
        subject: "<linkage/1615>",
        predicate: "matchesOSM",
        object: "<lgd:way83730096>",
      },
      {
        subject: "<linkage/1615>",
        predicate: "matchesCityGML",
        object: "<gmlid/DEBY_LOD2_4959530_24fea1bd-654b-4d61-bc6d-b43637979f62_2>",
      },
      {
        subject: "<gmlid/DEBY_LOD2_4959530_24fea1bd-654b-4d61-bc6d-b43637979f62_2>",
        predicate: "mapsurface",
        object: "<cityobject/75058>",
      },
      {
        subject: "<cityobject/75058>",
        predicate: "bldg:bounds",
        object: "<cityobject/75027>",
      },
      { subject: "<cityobject/75027>", predicate: "a", object: "bldg:Building"},
      { subject: "<cityobject/75027>", predicate: "bldg:measuredHeight", object: "\"2.166\""},
      { subject: "<osmlink/8709>", predicate: "hasclassid", object: "<osmclassid/3>"},
      { subject: "<osmlink/8709>", predicate: "hasosmid", object: "<lgd:way83730096>"},
      { subject: "<osmclassid/3>", predicate: "a", object: "<lgdo:Hotel>"},
      { subject: "<cityobject/75058>", predicate: "geo:hasGeometry", object: "<geometry/364582>"},
      { subject: "<geometry/364582>", predicate: "geo:asWKT", object: "\"POLYGON Z ((11.575964630307361 48.14750615033712 514.286,11.575885347137987 48.14752853362413 514.286,11.575940865317556 48.14761690811896 514.286,11.575961287137481 48.147611231329655 514.286,11.576018980365003 48.147595360806505 514.286,11.576001607620562 48.14755184044637 514.286,11.57603590035615 48.14753586484734 514.286,11.576083471887 48.14752193089773 514.286,11.576058632106639 48.14747965776385 514.286,11.575964630307361 48.14750615033712 514.286))\""},
    ];

    var graph = triplesToGraph(triples);
    const svg = d3.select("svg").attr("width", width).attr("height", height);

    var force = d3.forceSimulation(graph.nodes);

    function dragstart() {
      d3.select(this).classed("fixed", true);
    }

    function clamp(x, lo, hi) {
      return x < lo ? lo : x > hi ? hi : x;
    }

    function dragged(event, d) {
      d.fx = clamp(event.x, 0, width);
      d.fy = clamp(event.y, 0, height);
      force.alpha(1).restart();
    }

    const drag = d3.drag().on("start", dragstart).on("drag", dragged);

    svg
        .append("svg:defs")
        .selectAll("marker")
        .data(["end"])
        .enter()
        .append("svg:marker")
        .attr("id", String)
        .attr("viewBox", "0 -5 10 10")
        .attr("refX", 30)
        .attr("refY", -0.5)
        .attr("markerWidth", 6)
        .attr("markerHeight", 6)
        .attr("orient", "auto")
        .append("svg:polyline")
        .attr("points", "0,-5 10,0 0,5");

    var links = svg
        .selectAll(".link")
        .data(graph.links)
        .enter()
        .append("line")
        .attr("marker-end", "url(#end)")
        .attr("class", "link")
        .attr("stroke-width", 1); //links
    // ==================== Add Link Names =====================
    var linkTexts = svg
        .selectAll(".link-text")
        .data(graph.links)
        .enter()
        .append("text")
        .attr("class", "link-text")
        .text(function (d) {
          return d.predicate;
        });
    // ==================== Add Link Names =====================
    var nodeTexts = svg
        .selectAll(".node-text")
        .data(graph.nodes)
        .enter()
        .append("text")
        .attr("class", "node-text")
        .text(function (d) {
          return d.label;
        });
    // ==================== Add Node =====================
    var nodes = svg
        .selectAll(".node")
        .data(graph.nodes)
        .enter()
        .append("circle")
        .attr("class", "node")
        .attr("r", 8)
        .call(drag);

    function ticked() {
      nodes
          .attr("cx", function (d) {
            return d.x;
          })
          .attr("cy", function (d) {
            return d.y;
          });

      links
          .attr("x1", function (d) {
            return d.source.x;
          })
          .attr("y1", function (d) {
            return d.source.y;
          })
          .attr("x2", function (d) {
            return d.target.x;
          })
          .attr("y2", function (d) {
            return d.target.y;
          });

      nodeTexts
          .attr("x", function (d) {
            return d.x + 12;
          })
          .attr("y", function (d) {
            return d.y + 3;
          });

      linkTexts
          .attr("x", function (d) {
            return 4 + (d.source.x + d.target.x) / 2;
          })
          .attr("y", function (d) {
            return 4 + (d.source.y + d.target.y) / 2;
          });
    }

    force.on("tick", ticked);

    force
        .force(
            "link",
            d3.forceLink(graph.links).id((d) => d.id)
        )
        .force("charge", d3.forceManyBody())
        .force("center", d3.forceCenter(width / 2, height / 2));
  },
};
</script>
<style type="text/css">
.node {
  stroke: #fff;
  fill: #ddd;
  stroke-width: 1.5px;
}

.link {
  stroke: #999;
  stroke-opacity: 0.6;
  stroke-width: 1px;
}

marker {
  stroke: #999;
  fill: rgba(124, 240, 10, 0);
}

.node-text {
  font: 11px sans-serif;
  fill: black;
}

.link-text {
  font: 9px sans-serif;
  fill: grey;
}

svg {
  border: 1px solid black;
}
</style>