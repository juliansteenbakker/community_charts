// Copyright 2018 the Charts project authors. Please see the AUTHORS file
// for details.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:math' show Rectangle;

import '../../common/color.dart';
import '../../common/graphics_factory.dart';
import '../../common/text_style.dart';
import '../cartesian/axis/spec/axis_spec.dart';
import '../common/chart_canvas.dart';
import 'point_renderer.dart';
import 'point_renderer_decorator.dart';

class PointLabelSpec {
  final String label;
  final bool selected;
  PointLabelSpec({
    required this.label,
    this.selected = false,
  });
}

typedef LabelCallback = PointLabelSpec Function(Object? datum);

class PointLabelDecorator<D> extends PointRendererDecorator<D> {
  final int horizontalPadding;
  final int verticalPadding;

  final TextStyleSpec? labelStyleSpec;
  final TextStyleSpec? selectedLabelStyleSpec;
  final LabelCallback labelCallback;
  TextStyle? _labelStyle;
  TextStyle? _selectedLabelStyle;

  PointLabelDecorator(
      {this.labelStyleSpec,
      this.selectedLabelStyleSpec,
      required this.labelCallback,
      this.horizontalPadding = 0,
      this.verticalPadding = 0});

  @override
  bool get renderAbove => true;

  @override
  void decorate(PointRendererElement<D> pointElement, ChartCanvas canvas,
      GraphicsFactory graphicsFactory,
      {required Rectangle drawBounds,
      required double animationPercent,
      bool rtl = false}) {
    // Only decorate the bars when animation is at 100%.
    if (animationPercent != 1.0) {
      return;
    }

    if (_labelStyle == null) {
      _initLabelStyle(graphicsFactory);
    }

    final labelInfo = labelCallback(pointElement.point?.datum);
    final labelElement = graphicsFactory.createTextElement(labelInfo.label)
      ..textStyle = labelInfo.selected ? _selectedLabelStyle : _labelStyle;
    final point = pointElement.point;
    if (point == null || point.x == null || point.y == null) return;

    final labelX = point.x!.toInt() - horizontalPadding;
    final labelY = point.y!.toInt() - verticalPadding;

    canvas.drawText(labelElement, labelX, labelY);
  }

  void _initLabelStyle(GraphicsFactory graphicsFactory) {
    _labelStyle = _textStyleFromSpec(graphicsFactory, labelStyleSpec);
    _selectedLabelStyle = selectedLabelStyleSpec != null
        ? _textStyleFromSpec(graphicsFactory, selectedLabelStyleSpec)
        : _labelStyle;
  }

  TextStyle? _textStyleFromSpec(
      GraphicsFactory graphicsFactory, TextStyleSpec? spec) {
    return graphicsFactory.createTextPaint()
      ..color = spec?.color ?? const Color(r: 0, g: 0, b: 0)
      ..fontFamily = spec?.fontFamily
      ..fontSize = spec?.fontSize ?? 12
      ..fontWeight = spec?.fontWeight ?? '400';
  }
}
