import 'dart:math';
import 'package:flutter/material.dart';
import '../themes.dart';

class NatalChartWheel extends StatelessWidget {
  final Map<String, double> longitudes;
  final List<double> cusps;
  final List<String> aspects;

  const NatalChartWheel({
    super.key,
    required this.longitudes,
    required this.cusps,
    required this.aspects,
  });

  @override
  Widget build(BuildContext context) {
    // Maximize size to exactly fit the screen width minus horizontal padding (16.0 * 2 = 32.0)
    final size = MediaQuery.of(context).size.width - 32.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? const Color(0xFF0E0E12) : const Color(0xFFFFFDF6),
        boxShadow: [Themes.cardShadow(isDark)],
        border: Border.all(color: Themes.gold.withValues(alpha: isDark ? 0.15 : 0.4), width: 1.5),
      ),
      child: ClipOval(
        child: CustomPaint(
          size: Size(size, size),
          painter: NatalChartPainter(
            longitudes: longitudes,
            cusps: cusps,
            aspects: aspects,
            isDark: isDark,
          ),
        ),
      ),
    );
  }
}

class NatalChartPainter extends CustomPainter {
  final Map<String, double> longitudes;
  final List<double> cusps;
  final List<String> aspects;
  final bool isDark;

  NatalChartPainter({
    required this.longitudes,
    required this.cusps,
    required this.aspects,
    required this.isDark,
  });

  // Astrological Unicode symbols with Variation Selector-15 (\u{FE0E}) to force monochrome text rendering
  static const Map<String, String> planetSymbols = {
    'Sun': '☉\u{FE0E}',
    'Moon': '☽\u{FE0E}',
    'Mercury': '☿\u{FE0E}',
    'Venus': '♀\u{FE0E}',
    'Mars': '♂\u{FE0E}',
    'Jupiter': '♃\u{FE0E}',
    'Saturn': '♄\u{FE0E}',
    'Uranus': '♅\u{FE0E}',
    'Neptune': '♆\u{FE0E}',
    'Pluto': '♇\u{FE0E}',
    'Chiron': '⚷\u{FE0E}',
    'NorthNode': '☊\u{FE0E}',
    'SouthNode': '☋\u{FE0E}',
    'Fortune': '⨂\u{FE0E}',
    'Lilith': '⚸\u{FE0E}',
    'Ceres': '⚳\u{FE0E}',
    'Pallas': '⚴\u{FE0E}',
    'Juno': '⚵\u{FE0E}',
    'Vesta': '⚶\u{FE0E}',
    'Ascendant': 'Asc',
    'MC': 'MC',
  };

  // Zodiac Sign symbols with Variation Selector-15 (\u{FE0E}) to prevent emoji representation
  static const List<String> zodiacSymbols = [
    '♈\u{FE0E}', '♉\u{FE0E}', '♊\u{FE0E}', '♋\u{FE0E}', '♌\u{FE0E}', '♍\u{FE0E}',
    '♎\u{FE0E}', '♏\u{FE0E}', '♐\u{FE0E}', '♑\u{FE0E}', '♒\u{FE0E}', '♓\u{FE0E}'
  ];

  // Element color coding for Cusp Signs
  Color _getElementColor(int zodiacIndex) {
    final elementIndex = zodiacIndex % 4;
    if (isDark) {
      switch (elementIndex) {
        case 0: return const Color(0xFFEF5350); // Fire (Red)
        case 1: return const Color(0xFF66BB6A); // Earth (Green)
        case 2: return const Color(0xFF29B6F6); // Air (Blue)
        case 3: return const Color(0xFFAB47BC); // Water (Purple)
        default: return Colors.grey;
      }
    } else {
      switch (elementIndex) {
        case 0: return const Color(0xFFD32F2F); // Fire (Rich Red)
        case 1: return const Color(0xFF2E7D32); // Earth (Rich Green)
        case 2: return const Color(0xFF1565C0); // Air (Rich Blue)
        case 3: return const Color(0xFF6A1B9A); // Water (Rich Purple)
        default: return Colors.grey;
      }
    }
  }

  // Planet color coding (AstroGold style)
  Color _getPlanetColor(String name) {
    if (isDark) {
      switch (name) {
        case 'Sun': return const Color(0xFFFFB300); // Gold-Orange
        case 'Moon': return const Color(0xFFCFD8DC); // Silver-Blue
        case 'Mercury': return const Color(0xFFAB47BC); // Purple
        case 'Venus': return const Color(0xFF26A69A); // Emerald Teal
        case 'Mars': return const Color(0xFFEF5350); // Bold Red
        case 'Jupiter': return const Color(0xFF42A5F5); // Royal Blue
        case 'Saturn': return const Color(0xFF8D6E63); // Earthy Brown
        case 'Uranus': return const Color(0xFF26C6DA); // Aquamarine
        case 'Neptune': return const Color(0xFF7E57C2); // Deep Violet
        case 'Pluto': return const Color(0xFFE57373); // Soft Red
        case 'Chiron': return const Color(0xFF66BB6A); // Green
        case 'NorthNode':
        case 'SouthNode': return const Color(0xFFECEFF1); // Light Grey
        case 'Fortune': return const Color(0xFFD4AF37); // Rich Gold
        case 'Lilith': return const Color(0xFFFF7043); // Coral
        default: return const Color(0xFFB0BEC5); // Asteroids
      }
    } else {
      switch (name) {
        case 'Sun': return const Color(0xFFE65100); // Darker Orange
        case 'Moon': return const Color(0xFF263238); // Dark Slate Grey
        case 'Mercury': return const Color(0xFF6A1B9A); // Dark Purple
        case 'Venus': return const Color(0xFF00695C); // Dark Teal
        case 'Mars': return const Color(0xFFC62828); // Dark Red
        case 'Jupiter': return const Color(0xFF1565C0); // Dark Blue
        case 'Saturn': return const Color(0xFF4E342E); // Dark Brown
        case 'Uranus': return const Color(0xFF00838F); // Dark Cyan
        case 'Neptune': return const Color(0xFF283593); // Dark Indigo
        case 'Pluto': return const Color(0xFFAD1457); // Dark Pink/Red
        case 'Chiron': return const Color(0xFF2E7D32); // Dark Green
        case 'NorthNode':
        case 'SouthNode': return const Color(0xFF212121); // Almost Black
        case 'Fortune': return const Color(0xFFB78A02); // Dark Gold
        case 'Lilith': return const Color(0xFFD84315); // Dark Orange-Red
        default: return const Color(0xFF455A64); // Dark Asteroids
      }
    }
  }

  // 4-Quadrant helper (unrotated text direction):
  // 3: Top (Vertical: [Planet] on top, [Minute] at bottom)
  // 1: Bottom (Vertical: [Minute] on top, [Planet] at bottom)
  // 2: Left (Horizontal: [Planet] on left, [Minute] on right)
  // 0: Right (Horizontal: [Minute] on left, [Planet] on right)
  int _getQuadrant(double deg) {
    final double norm = deg % 360.0;
    if (norm >= 45.0 && norm < 135.0) {
      return 1; // Bottom
    } else if (norm >= 135.0 && norm < 225.0) {
      return 2; // Left
    } else if (norm >= 225.0 && norm < 315.0) {
      return 3; // Top
    } else {
      return 0; // Right
    }
  }

  TextSpan _buildTextSpan(_PlanetDrawInfo info, int quadrant, TextStyle symbolStyle, TextStyle valueStyle, TextStyle signStyle) {
    switch (quadrant) {
      case 3: // Top: Vertical [Planet] -> [Degree] -> [Sign] -> [Minute]
        return TextSpan(
          children: [
            TextSpan(text: '${info.symbol}\n', style: symbolStyle),
            TextSpan(text: '${info.degStr}°\n', style: valueStyle),
            TextSpan(text: '${info.signSym}\n', style: signStyle),
            TextSpan(text: '${info.minStr}\'', style: valueStyle),
          ],
        );
      case 1: // Bottom: Vertical [Minute] -> [Sign] -> [Degree] -> [Planet]
        return TextSpan(
          children: [
            TextSpan(text: '${info.minStr}\'\n', style: valueStyle),
            TextSpan(text: '${info.signSym}\n', style: signStyle),
            TextSpan(text: '${info.degStr}°\n', style: valueStyle),
            TextSpan(text: info.symbol, style: symbolStyle),
          ],
        );
      case 2: // Left: Horizontal [Planet] [Degree] [Sign] [Minute]
        return TextSpan(
          children: [
            TextSpan(text: '${info.symbol} ', style: symbolStyle),
            TextSpan(text: '${info.degStr}° ', style: valueStyle),
            TextSpan(text: '${info.signSym} ', style: signStyle),
            TextSpan(text: '${info.minStr}\'', style: valueStyle),
          ],
        );
      case 0: // Right: Horizontal [Minute] [Sign] [Degree] [Planet]
      default:
        return TextSpan(
          children: [
            TextSpan(text: '${info.minStr}\' ', style: valueStyle),
            TextSpan(text: '${info.signSym} ', style: signStyle),
            TextSpan(text: '${info.degStr}° ', style: valueStyle),
            TextSpan(text: info.symbol, style: symbolStyle),
          ],
        );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Margins optimized to prevent horizontal unrotated labels from clipping at the canvas edge
    final outerRadius = size.width / 2 - 12.0; 
    final ringWidth = 20.0;
    final innerRadius = outerRadius - ringWidth;

    // Aspect circle and house number boundary definitions (AstroGold style)
    final aspectRadius = innerRadius * 0.44;
    final houseRadius = innerRadius * 0.54;

    // Helper functions for House-centric Wheel Projection
    // Maps a longitude (0-360) onto the equal 30-degree house slices of the wheel
    double getProjectedAngle(double lon) {
      if (cusps.length < 13) return 0.0;
      lon = lon % 360.0;

      // Find which house this longitude falls into
      int h = 1;
      for (int i = 1; i <= 12; i++) {
        double cStart = cusps[i];
        double cEnd = cusps[i == 12 ? 1 : i + 1];

        bool inside = false;
        if (cStart < cEnd) {
          inside = lon >= cStart && lon < cEnd;
        } else {
          inside = lon >= cStart || lon < cEnd;
        }

        if (inside) {
          h = i;
          break;
        }
      }

      double cStart = cusps[h];
      double cEnd = cusps[h == 12 ? 1 : h + 1];

      double diffTotal = cEnd - cStart;
      if (diffTotal < 0) diffTotal += 360.0;

      double diffPart = lon - cStart;
      if (diffPart < 0) diffPart += 360.0;

      double f = diffTotal > 0 ? (diffPart / diffTotal) : 0.0;

      // Houses go clockwise, starting with House 1 at 180 degrees (9 o'clock)
      double startAngle = (180.0 - (h - 1) * 30.0) % 360.0;
      double wheelDeg = (startAngle - f * 30.0) % 360.0;
      return wheelDeg;
    }

    double getProjectedRad(double lon) {
      return getProjectedAngle(lon) * pi / 180.0;
    }

    final paintLine = Paint()
      ..color = isDark 
          ? Themes.gold.withValues(alpha: 0.25)
          : const Color(0xFF8D6E63).withValues(alpha: 0.35)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    // 1. Draw Zodiac Sign Ring as a clean, solid background band (AstroGold style)
    final ringPaint = Paint()
      ..color = isDark ? const Color(0xFF16161F) : const Color(0xFFFBF9F3)
      ..style = PaintingStyle.fill;
    
    final ringPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: outerRadius))
      ..addOval(Rect.fromCircle(center: center, radius: innerRadius));
    canvas.drawPath(ringPath, ringPaint);

    final borderPaint = Paint()
      ..color = isDark 
          ? Themes.gold.withValues(alpha: 0.2)
          : const Color(0xFF8D6E63).withValues(alpha: 0.35)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, innerRadius, borderPaint);
    canvas.drawCircle(center, outerRadius, borderPaint);

    // Draw the secondary house boundary circle
    canvas.drawCircle(center, houseRadius, paintLine);

    // 2. Draw House Cusp Lines & Cusp Labels (Equal 30-degree slices)
    if (cusps.length >= 13) {
      for (int h = 1; h <= 12; h++) {
        // Cusp lines are drawn at exact 30-degree steps
        final cuspDegOnWheel = (180.0 - (h - 1) * 30.0) % 360.0;
        final cuspRad = cuspDegOnWheel * pi / 180.0;

        final isAngles = h == 1 || h == 10 || h == 4 || h == 7;
        final housePaint = Paint()
          ..color = isDark
              ? (isAngles ? Themes.gold.withValues(alpha: 0.5) : Themes.gold.withValues(alpha: 0.12))
              : (isAngles ? const Color(0xFF5D4037).withValues(alpha: 0.6) : const Color(0xFF8D6E63).withValues(alpha: 0.2))
          ..strokeWidth = isAngles ? 1.4 : 0.7
          ..style = PaintingStyle.stroke;

        // Cusp lines start exactly at the aspect circle boundary
        final startOffset = Offset(
          center.dx + aspectRadius * cos(cuspRad),
          center.dy + aspectRadius * sin(cuspRad),
        );
        // Cusp lines stop EXACTLY at innerRadius so they do not cross the Zodiac Ring behind the sign symbol
        final endOffset = Offset(
          center.dx + innerRadius * cos(cuspRad),
          center.dy + innerRadius * sin(cuspRad),
        );

        canvas.drawLine(startOffset, endOffset, housePaint);

        // Draw Cusp Sign & Degree/Minute Label (AstroGold style)
        final cuspLon = cusps[h];
        final signIdx = (cuspLon % 360 / 30).floor();
        final degWithin = cuspLon % 360 - (signIdx * 30);
        int d = degWithin.floor();
        int m = ((degWithin - d) * 60).round();
        if (m == 60) {
          d += 1;
          m = 0;
        }
        final degStr = d.toString().padLeft(2, '0');
        final minStr = m.toString().padLeft(2, '0');

        // Draw the combined label: [Degree] [Zodiac Sign] [Minute] inside the Zodiac Ring, unrotated (horizontal) for user convenience
        final cuspTextSpan = TextSpan(
          children: [
            TextSpan(
              text: '$degStr° ',
              style: TextStyle(
                color: isDark ? Themes.gold.withValues(alpha: 0.65) : const Color(0xFF5D4037).withValues(alpha: 0.85),
                fontSize: 8.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: zodiacSymbols[signIdx],
              style: TextStyle(
                color: _getElementColor(signIdx),
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: ' $minStr\'',
              style: TextStyle(
                color: isDark ? Themes.gold.withValues(alpha: 0.65) : const Color(0xFF5D4037).withValues(alpha: 0.85),
                fontSize: 8.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );

        final cuspTextPainter = TextPainter(
          text: cuspTextSpan,
          textDirection: TextDirection.ltr,
        )..layout();

        canvas.save();
        // Translate to the center of the Zodiac Ring at the cusp angle
        final double zodiacRadius = (innerRadius + outerRadius) / 2;
        final double textX = center.dx + zodiacRadius * cos(cuspRad);
        final double textY = center.dy + zodiacRadius * sin(cuspRad);
        canvas.translate(textX, textY);

        // ALWAYS keep text horizontal (rot = 0) so the user doesn't need to tilt their head
        // Paint the text centered at (0, 0)
        cuspTextPainter.paint(
          canvas,
          Offset(-cuspTextPainter.width / 2, -cuspTextPainter.height / 2),
        );
        canvas.restore();

        // Draw House Number Label centered in the narrow ring between aspectRadius and houseRadius
        final midHouseRad = (180.0 - (h - 1) * 30.0 - 15.0) * pi / 180.0;
        final midRingRadius = (aspectRadius + houseRadius) / 2;

        final houseTextSpan = TextSpan(
          text: '$h',
          style: TextStyle(
            color: isDark ? Themes.gold.withValues(alpha: 0.35) : const Color(0xFF5D4037).withValues(alpha: 0.7),
            fontSize: 9.0,
            fontWeight: FontWeight.bold,
          ),
        );
        final houseTextPainter = TextPainter(
          text: houseTextSpan,
          textDirection: TextDirection.ltr,
        )..layout();

        final houseTextPos = Offset(
          center.dx + midRingRadius * cos(midHouseRad) - houseTextPainter.width / 2,
          center.dy + midRingRadius * sin(midHouseRad) - houseTextPainter.height / 2,
        );
        houseTextPainter.paint(canvas, houseTextPos);
      }
    }

    // 3. Draw Aspect Lines (Connected between projected planet locations inside the aspect circle)
    final aspectPaint = Paint()..strokeWidth = 0.8;
    for (final aspectStr in aspects) {
      final parts = aspectStr.split('-');
      if (parts.length < 3) continue;
      final p1 = parts[0];
      final p2 = parts[1];
      final type = parts[2];

      final deg1 = longitudes[p1];
      final deg2 = longitudes[p2];
      if (deg1 == null || deg2 == null) continue;

      final rad1 = getProjectedRad(deg1);
      final rad2 = getProjectedRad(deg2);

      if (type == 'Conjunction') {
        aspectPaint.color = isDark ? Themes.gold.withValues(alpha: 0.3) : const Color(0xFF8D6E63).withValues(alpha: 0.35);
      } else if (type == 'Square' || type == 'Opposition') {
        aspectPaint.color = const Color(0xFFEF5350).withValues(alpha: isDark ? 0.35 : 0.6);
      } else {
        aspectPaint.color = const Color(0xFF29B6F6).withValues(alpha: isDark ? 0.35 : 0.6);
      }

      final p1Offset = Offset(
        center.dx + aspectRadius * cos(rad1),
        center.dy + aspectRadius * sin(rad1),
      );
      final p2Offset = Offset(
        center.dx + aspectRadius * cos(rad2),
        center.dy + aspectRadius * sin(rad2),
      );

      canvas.drawLine(p1Offset, p2Offset, aspectPaint);
    }

    canvas.drawCircle(center, aspectRadius, paintLine);
    canvas.drawCircle(center, 3, Paint()..color = Themes.gold.withValues(alpha: 0.4));

    // 4. Group Planets into Clusters (AstroGold-style Stack Rendering)
    final plotPlanets = [
      'Sun', 'Moon', 'Mercury', 'Venus', 'Mars', 'Jupiter', 'Saturn', 'Uranus', 'Neptune', 'Pluto', 'Chiron',
      'NorthNode', 'SouthNode', 'Fortune', 'Lilith', 'Ceres', 'Pallas', 'Juno', 'Vesta'
    ];

    final List<_PlanetDrawInfo> planetInfos = [];
    for (final name in plotPlanets) {
      final deg = longitudes[name];
      if (deg == null) continue;

      // Project longitude onto the equal house wheel angle
      final actualAngle = getProjectedAngle(deg);

      final signIdx = (deg % 360 / 30).floor();
      final degWithin = deg % 360 - (signIdx * 30);
      int d = degWithin.floor();
      int m = ((degWithin - d) * 60).round();
      if (m == 60) {
        d += 1;
        m = 0;
      }
      
      planetInfos.add(_PlanetDrawInfo(
        name: name,
        symbol: planetSymbols[name] ?? name,
        actualLongitude: deg,
        actualAngle: actualAngle,
        adjustedAngle: actualAngle,
        degStr: d.toString().padLeft(2, '0'),
        signSym: zodiacSymbols[signIdx],
        minStr: m.toString().padLeft(2, '0'),
        signColor: _getElementColor(signIdx),
      ));
    }

    planetInfos.sort((a, b) => a.actualAngle.compareTo(b.actualAngle));

    // Grouping planets into clusters that are close to each other on the wheel
    // Set cluster threshold to 13.0 degrees so planets in different houses are not clustered together
    final List<List<_PlanetDrawInfo>> clusters = [];
    if (planetInfos.isNotEmpty) {
      List<_PlanetDrawInfo> currentCluster = [planetInfos[0]];
      for (int i = 1; i < planetInfos.length; i++) {
        final prev = planetInfos[i - 1];
        final curr = planetInfos[i];
        double diff = curr.actualAngle - prev.actualAngle;
        if (diff < 0) diff += 360;

        if (diff < 13.0) {
          currentCluster.add(curr);
        } else {
          clusters.add(currentCluster);
          currentCluster = [curr];
        }
      }
      clusters.add(currentCluster);

      // Handle circle wrap-around merging
      if (clusters.length > 1) {
        final first = clusters.first;
        final last = clusters.last;
        double diff = first.first.actualAngle - last.last.actualAngle;
        if (diff < 0) diff += 360;
        if (diff < 13.0) {
          first.insertAll(0, last);
          clusters.removeLast();
        }
      }
    }

    // 6. Calculate Radial Staggering Levels for Single Planets to avoid collision while staying in their respective houses
    final List<_PlanetDrawInfo> singlePlanets = [];
    for (final cluster in clusters) {
      if (cluster.length == 1) {
        singlePlanets.add(cluster.first);
      }
    }
    singlePlanets.sort((a, b) => a.actualAngle.compareTo(b.actualAngle));

    final Map<String, int> staggerLevels = {};
    if (singlePlanets.isNotEmpty) {
      staggerLevels[singlePlanets[0].name] = 0;
      for (int i = 1; i < singlePlanets.length; i++) {
        final prev = singlePlanets[i - 1];
        final curr = singlePlanets[i];
        double diff = curr.actualAngle - prev.actualAngle;
        if (diff < 0) diff += 360;

        // If adjacent single planets are within 18 degrees, stagger their radial positions (0 and 1)
        if (diff < 18.0) {
          final prevLevel = staggerLevels[prev.name] ?? 0;
          staggerLevels[curr.name] = 1 - prevLevel;
        } else {
          staggerLevels[curr.name] = 0;
        }
      }
      // Circle wrap-around check for first and last single planets
      if (singlePlanets.length > 1) {
        final first = singlePlanets.first;
        final last = singlePlanets.last;
        double diff = first.actualAngle - last.actualAngle;
        if (diff < 0) diff += 360;
        if (diff < 18.0) {
          final lastLevel = staggerLevels[last.name] ?? 0;
          if (lastLevel == 0) {
            staggerLevels[first.name] = 1;
          }
        }
      }
    }

    // 7. Draw the Planets (Single labels or Stacked lists with Leader Lines)
    for (final cluster in clusters) {
      if (cluster.isEmpty) continue;

      if (cluster.length == 1) {
        // Single planet - Orthogonal layout determined by 4-quadrant algorithm (ALWAYS unrotated text for readability)
        final info = cluster.first;
        final radActual = info.actualAngle * pi / 180.0;
        
        final dotPaint = Paint()..color = isDark ? Themes.gold.withValues(alpha: 0.6) : const Color(0xFF8D6E63).withValues(alpha: 0.75);
        final dotPos = Offset(
          center.dx + innerRadius * cos(radActual),
          center.dy + innerRadius * sin(radActual),
        );
        canvas.drawCircle(dotPos, 2.0, dotPaint);

        final isImportant = info.name == 'Sun' || info.name == 'Moon';
        final planetColor = _getPlanetColor(info.name);

        final int quadrant = _getQuadrant(info.actualAngle);

        // Restored clean, compact font sizes exactly as requested
        final symbolStyle = TextStyle(
          color: planetColor,
          fontSize: isImportant ? 13.5 : 10.5,
          fontWeight: FontWeight.bold,
          height: 1.1,
        );
        final valueStyle = TextStyle(
          color: info.signColor,
          fontSize: 7.5,
          fontWeight: FontWeight.w600,
          height: 1.1,
        );
        final signStyle = TextStyle(
          color: info.signColor,
          fontSize: 8.0,
          fontWeight: FontWeight.bold,
          height: 1.1,
        );

        final TextSpan textSpan = _buildTextSpan(info, quadrant, symbolStyle, valueStyle, signStyle);
        final textPainter = TextPainter(
          text: textSpan,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        )..layout();

        final double labelHalfWidth = textPainter.width / 2;
        final double labelHalfHeight = textPainter.height / 2;

        final int staggerLevel = staggerLevels[info.name] ?? 0;
        final double staggerOffset = staggerLevel * 10.0; // Restored original stagger spacing

        // Position of label center
        final double radialOffset = (labelHalfWidth * cos(radActual).abs()) + (labelHalfHeight * sin(radActual).abs());
        
        // Clamp radius keeping a 5px margin inside innerRadius (safe since cusp labels are outside)
        final double minRadius = houseRadius + 5.0 + radialOffset;
        final double maxRadius = innerRadius - 5.0 - radialOffset;
        double labelRadius;
        
        if (minRadius > maxRadius) {
          labelRadius = (houseRadius + innerRadius) / 2;
        } else {
          labelRadius = (innerRadius - 5.0 - radialOffset - staggerOffset).clamp(minRadius, maxRadius);
        }

        final labelPos = Offset(
          center.dx + labelRadius * cos(radActual),
          center.dy + labelRadius * sin(radActual),
        );

        // Paint unrotated horizontal text
        textPainter.paint(
          canvas,
          Offset(labelPos.dx - textPainter.width / 2, labelPos.dy - textPainter.height / 2),
        );

        // Connect leader line directly to the planet symbol (outermost part of the text block)
        Offset targetPos;
        switch (quadrant) {
          case 3: // Top: symbol is at the top
            targetPos = Offset(labelPos.dx, labelPos.dy - textPainter.height / 2);
            break;
          case 1: // Bottom: symbol is at the bottom
            targetPos = Offset(labelPos.dx, labelPos.dy + textPainter.height / 2);
            break;
          case 2: // Left: symbol is on the left
            targetPos = Offset(labelPos.dx - textPainter.width / 2, labelPos.dy);
            break;
          case 0: // Right: symbol is on the right
          default:
            targetPos = Offset(labelPos.dx + textPainter.width / 2, labelPos.dy);
            break;
        }

        // Draw leader line for EVERY single planet to clearly link the text to its actual coordinate
        final linePaint = Paint()
          ..color = isDark ? Themes.gold.withValues(alpha: 0.15) : const Color(0xFF8D6E63).withValues(alpha: 0.25)
          ..strokeWidth = 0.5;

        canvas.drawLine(dotPos, targetPos, linePaint);
      } else {
        // Multi-planet cluster: Stack them side-by-side (Top/Bottom quadrants) or vertically (Left/Right quadrants)
        double sumX = 0;
        double sumY = 0;
        for (final info in cluster) {
          final rad = info.actualAngle * pi / 180.0;
          sumX += cos(rad);
          sumY += sin(rad);
        }
        final avgRad = atan2(sumY, sumX);
        final double avgAngle = avgRad * 180.0 / pi;

        final int quadrant = _getQuadrant(avgAngle);
        final bool isVertical = quadrant == 3 || quadrant == 1;

        // Sort cluster to prevent crossed leader lines:
        // - Vertical layout (Top/Bottom side-by-side): Sort by X-coordinate (cos) to match horizontal sequence
        // - Horizontal layout (Left/Right stacked): Sort by Y-coordinate (sin) to match vertical sequence
        if (isVertical) {
          cluster.sort((a, b) {
            final xA = cos(a.actualAngle * pi / 180.0);
            final xB = cos(b.actualAngle * pi / 180.0);
            return xA.compareTo(xB);
          });
        } else {
          cluster.sort((a, b) {
            final yA = sin(a.actualAngle * pi / 180.0);
            final yB = sin(b.actualAngle * pi / 180.0);
            return yA.compareTo(yB);
          });
        }

        final N = cluster.length;
        double stackHalfWidth;
        double stackHalfHeight;
        final double rowHeight = 12.0; // Restored original compact row height
        final double colWidth = 18.0;  // Restored original compact col width

        if (isVertical) {
          // Top/Bottom: Stack horizontally side-by-side
          stackHalfHeight = 18.0; // Half height of a vertical text label
          stackHalfWidth = (N * colWidth) / 2;
        } else {
          // Left/Right: Stack vertically top-to-bottom
          stackHalfHeight = (N * rowHeight) / 2;
          stackHalfWidth = 22.0; // Half width of a horizontal text label
        }

        final double radialOffset = (stackHalfWidth * cos(avgRad).abs()) + (stackHalfHeight * sin(avgRad).abs());
        
        // Clamp the stack label radius to always stay outside the house numbering ring and inside innerRadius boundary
        final double minRadius = houseRadius + 5.0 + radialOffset;
        final double maxRadius = innerRadius - 5.0 - radialOffset;
        double adjustedLabelRadius;

        if (minRadius > maxRadius) {
          adjustedLabelRadius = (houseRadius + innerRadius) / 2;
        } else {
          adjustedLabelRadius = (innerRadius - 5.0 - radialOffset).clamp(minRadius, maxRadius);
        }

        final stackCenterPos = Offset(
          center.dx + adjustedLabelRadius * cos(avgRad),
          center.dy + adjustedLabelRadius * sin(avgRad),
        );

        for (int i = 0; i < N; i++) {
          final info = cluster[i];
          final radActual = info.actualAngle * pi / 180.0;

          // Draw tick dot on the circle boundary
          final dotPaint = Paint()..color = isDark ? Themes.gold.withValues(alpha: 0.6) : const Color(0xFF8D6E63).withValues(alpha: 0.75);
          final dotPos = Offset(
            center.dx + innerRadius * cos(radActual),
            center.dy + innerRadius * sin(radActual),
          );
          canvas.drawCircle(dotPos, 2.0, dotPaint);

          final isImportant = info.name == 'Sun' || info.name == 'Moon';
          final planetColor = _getPlanetColor(info.name);

          // Restored compact font sizes for cluster stacks
          final symbolStyle = TextStyle(
            color: planetColor,
            fontSize: isImportant ? 13.5 : 10.5,
            fontWeight: FontWeight.bold,
            height: 1.1,
          );
          final valueStyle = TextStyle(
            color: info.signColor,
            fontSize: 7.5,
            fontWeight: FontWeight.w600,
            height: 1.1,
          );
          final signStyle = TextStyle(
            color: info.signColor,
            fontSize: 8.0,
            fontWeight: FontWeight.bold,
            height: 1.1,
          );

          final TextSpan textSpan = _buildTextSpan(info, quadrant, symbolStyle, valueStyle, signStyle);
          final textPainter = TextPainter(
            text: textSpan,
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
          )..layout();

          double labelX;
          double labelY;

          if (isVertical) {
            // Horizontal sequence of columns
            labelX = stackCenterPos.dx - ((N - 1) * colWidth / 2) + (i * colWidth);
            labelY = stackCenterPos.dy;
          } else {
            // Vertical sequence of rows
            labelX = stackCenterPos.dx;
            labelY = stackCenterPos.dy - ((N - 1) * rowHeight / 2) + (i * rowHeight);
          }

          final labelPos = Offset(labelX, labelY);

          // Paint unrotated horizontal/vertical text at its stack position
          textPainter.paint(
            canvas,
            Offset(labelPos.dx - textPainter.width / 2, labelPos.dy - textPainter.height / 2),
          );

          // Connect leader line directly to the planet symbol (the outer edge of the text block)
          Offset targetPos;
          switch (quadrant) {
            case 3: // Top: symbol is at the top
              targetPos = Offset(labelPos.dx, labelPos.dy - textPainter.height / 2);
              break;
            case 1: // Bottom: symbol is at the bottom
              targetPos = Offset(labelPos.dx, labelPos.dy + textPainter.height / 2);
              break;
            case 2: // Left: symbol is on the left
              targetPos = Offset(labelPos.dx - textPainter.width / 2, labelPos.dy);
              break;
            case 0: // Right: symbol is on the right
            default:
              targetPos = Offset(labelPos.dx + textPainter.width / 2, labelPos.dy);
              break;
          }

          // Draw thin Leader Line from the tick dot to the planet symbol
          final linePaint = Paint()
            ..color = isDark ? Themes.gold.withValues(alpha: 0.25) : const Color(0xFF8D6E63).withValues(alpha: 0.4)
            ..strokeWidth = 0.6
            ..style = PaintingStyle.stroke;

          canvas.drawLine(
            dotPos,
            targetPos,
            linePaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant NatalChartPainter oldDelegate) {
    return oldDelegate.longitudes != longitudes ||
        oldDelegate.cusps != cusps ||
        oldDelegate.aspects != aspects ||
        oldDelegate.isDark != isDark;
  }
}

class _PlanetDrawInfo {
  final String name;
  final String symbol;
  final double actualLongitude;
  final double actualAngle;
  double adjustedAngle;
  final String degStr;
  final String signSym;
  final String minStr;
  final Color signColor;

  _PlanetDrawInfo({
    required this.name,
    required this.symbol,
    required this.actualLongitude,
    required this.actualAngle,
    required this.adjustedAngle,
    required this.degStr,
    required this.signSym,
    required this.minStr,
    required this.signColor,
  });
}
