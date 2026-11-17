import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';
import 'package:progression_tracker/features/body/domain/entities/muscle_region.dart';

/// Pre-parsed 2D vector paths and silhouette geometries for the IronFlow Body Map.
///
/// Standard viewBox coordinate system: 300 x 520 (Center X = 150).
/// Scales cleanly to any target Canvas via [Canvas.scale].
class BodyMapPaths {
  const BodyMapPaths._();

  static const double viewBoxWidth = 300.0;
  static const double viewBoxHeight = 520.0;

  // ── Helpers ───────────────────────────────────────────────────────────────

  static Path _polygon(List<Offset> points) {
    final path = Path();
    if (points.isEmpty) return path;
    path.moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();
    return path;
  }

  static Path _mirrorX(Path source, double centerX) {
    // 4x4 matrix for mirroring across X = centerX in column-major order:
    // x' = -x + 2*centerX, y' = y, z' = z
    final matrixStorage = Float64List.fromList([
      -1.0, 0.0, 0.0, 0.0, // col 0
      0.0, 1.0, 0.0, 0.0,  // col 1
      0.0, 0.0, 1.0, 0.0,  // col 2
      2 * centerX, 0.0, 0.0, 1.0, // col 3
    ]);
    return source.transform(matrixStorage);
  }

  // ── Front View Paths ──────────────────────────────────────────────────────

  static Map<MuscleRegion, List<Path>> get frontRegionPaths => _frontRegionPaths;

  static final Map<MuscleRegion, List<Path>> _frontRegionPaths = () {
    const cx = 150.0;

    // Head / Neck (aesthetic outline)
    // Left Upper Trap
    final lTrap = _polygon(const [
      Offset(138, 82),
      Offset(108, 106),
      Offset(128, 114),
      Offset(138, 96),
    ]);
    final rTrap = _mirrorX(lTrap, cx);

    // Front Delts
    final lFrontDelt = _polygon(const [
      Offset(108, 106),
      Offset(86, 122),
      Offset(90, 154),
      Offset(112, 142),
      Offset(118, 118),
    ]);
    final rFrontDelt = _mirrorX(lFrontDelt, cx);

    // Side Delts
    final lSideDelt = _polygon(const [
      Offset(86, 122),
      Offset(72, 142),
      Offset(76, 168),
      Offset(90, 154),
    ]);
    final rSideDelt = _mirrorX(lSideDelt, cx);

    // Chest (Pectoralis Major)
    final lChest = _polygon(const [
      Offset(148, 116),
      Offset(118, 116),
      Offset(112, 142),
      Offset(116, 164),
      Offset(148, 164),
    ]);
    final rChest = _mirrorX(lChest, cx);

    // Biceps
    final lBicep = _polygon(const [
      Offset(88, 156),
      Offset(76, 178),
      Offset(84, 216),
      Offset(98, 212),
      Offset(106, 168),
    ]);
    final rBicep = _mirrorX(lBicep, cx);

    // Forearms
    final lForearm = _polygon(const [
      Offset(80, 220),
      Offset(66, 258),
      Offset(74, 300),
      Offset(86, 296),
      Offset(96, 232),
    ]);
    final rForearm = _mirrorX(lForearm, cx);

    // Upper Abs (4 quadrants)
    final upperAbsTopLeft = _polygon(const [
      Offset(132, 168),
      Offset(148, 168),
      Offset(148, 186),
      Offset(132, 186),
    ]);
    final upperAbsTopRight = _polygon(const [
      Offset(152, 168),
      Offset(168, 168),
      Offset(168, 186),
      Offset(152, 186),
    ]);
    final upperAbsBottomLeft = _polygon(const [
      Offset(132, 188),
      Offset(148, 188),
      Offset(148, 206),
      Offset(132, 206),
    ]);
    final upperAbsBottomRight = _polygon(const [
      Offset(152, 188),
      Offset(168, 188),
      Offset(168, 206),
      Offset(152, 206),
    ]);

    // Lower Abs (2 lower segments)
    final lowerAbsLeft = _polygon(const [
      Offset(132, 209),
      Offset(148, 209),
      Offset(148, 246),
      Offset(134, 246),
    ]);
    final lowerAbsRight = _polygon(const [
      Offset(152, 209),
      Offset(168, 209),
      Offset(166, 246),
      Offset(152, 246),
    ]);

    // Obliques
    final lOblique = _polygon(const [
      Offset(116, 168),
      Offset(128, 172),
      Offset(128, 244),
      Offset(116, 248),
      Offset(108, 206),
    ]);
    final rOblique = _mirrorX(lOblique, cx);

    // Quadriceps
    final lQuad = _polygon(const [
      Offset(114, 254),
      Offset(144, 254),
      Offset(140, 372),
      Offset(118, 372),
      Offset(98, 308),
    ]);
    final rQuad = _mirrorX(lQuad, cx);

    // Adductors
    final lAdductor = _polygon(const [
      Offset(144, 260),
      Offset(146, 324),
      Offset(136, 324),
    ]);
    final rAdductor = _mirrorX(lAdductor, cx);

    // Calves / Shin
    final lCalf = _polygon(const [
      Offset(116, 388),
      Offset(104, 422),
      Offset(114, 472),
      Offset(130, 472),
      Offset(134, 412),
    ]);
    final rCalf = _mirrorX(lCalf, cx);

    return {
      MuscleRegion.upperTraps: [lTrap, rTrap],
      MuscleRegion.frontDelts: [lFrontDelt, rFrontDelt],
      MuscleRegion.sideDelts: [lSideDelt, rSideDelt],
      MuscleRegion.chest: [lChest, rChest],
      MuscleRegion.biceps: [lBicep, rBicep],
      MuscleRegion.forearms: [lForearm, rForearm],
      MuscleRegion.upperAbs: [
        upperAbsTopLeft,
        upperAbsTopRight,
        upperAbsBottomLeft,
        upperAbsBottomRight,
      ],
      MuscleRegion.lowerAbs: [lowerAbsLeft, lowerAbsRight],
      MuscleRegion.obliques: [lOblique, rOblique],
      MuscleRegion.adductors: [lAdductor, rAdductor],
      MuscleRegion.quads: [lQuad, rQuad],
      MuscleRegion.calves: [lCalf, rCalf],
    };
  }();

  // ── Back View Paths ───────────────────────────────────────────────────────

  static Map<MuscleRegion, List<Path>> get backRegionPaths => _backRegionPaths;

  static final Map<MuscleRegion, List<Path>> _backRegionPaths = () {
    const cx = 150.0;

    // Upper Traps (Back Diamond)
    final trapsBack = _polygon(const [
      Offset(150, 78),
      Offset(110, 106),
      Offset(136, 154),
      Offset(150, 186),
      Offset(164, 154),
      Offset(190, 106),
    ]);

    // Middle Back / Rhomboids
    final lMidBack = _polygon(const [
      Offset(136, 154),
      Offset(150, 186),
      Offset(136, 216),
      Offset(126, 192),
    ]);
    final rMidBack = _mirrorX(lMidBack, cx);

    // Rear Delts
    final lRearDelt = _polygon(const [
      Offset(108, 108),
      Offset(84, 124),
      Offset(88, 158),
      Offset(114, 142),
    ]);
    final rRearDelt = _mirrorX(lRearDelt, cx);

    // Triceps
    final lTricep = _polygon(const [
      Offset(84, 160),
      Offset(70, 186),
      Offset(78, 224),
      Offset(96, 218),
      Offset(104, 172),
    ]);
    final rTricep = _mirrorX(lTricep, cx);

    // Forearms Back
    final lForearmBack = _polygon(const [
      Offset(80, 224),
      Offset(66, 258),
      Offset(74, 300),
      Offset(86, 296),
      Offset(96, 232),
    ]);
    final rForearmBack = _mirrorX(lForearmBack, cx);

    // Lats (V-Taper)
    final lLat = _polygon(const [
      Offset(122, 144),
      Offset(108, 172),
      Offset(116, 226),
      Offset(136, 230),
      Offset(138, 172),
    ]);
    final rLat = _mirrorX(lLat, cx);

    // Lower Back (Erector Spinae)
    final lowerBack = _polygon(const [
      Offset(136, 232),
      Offset(164, 232),
      Offset(162, 266),
      Offset(138, 266),
    ]);

    // Glutes
    final lGlute = _polygon(const [
      Offset(110, 268),
      Offset(148, 268),
      Offset(148, 320),
      Offset(108, 312),
      Offset(104, 284),
    ]);
    final rGlute = _mirrorX(lGlute, cx);

    // Abductors (Gluteus Medius / Hip Abductor)
    final lAbductor = _polygon(const [
      Offset(102, 268),
      Offset(110, 268),
      Offset(108, 312),
      Offset(98, 296),
    ]);
    final rAbductor = _mirrorX(lAbductor, cx);

    // Hamstrings
    final lHamstring = _polygon(const [
      Offset(108, 324),
      Offset(148, 324),
      Offset(142, 382),
      Offset(116, 382),
      Offset(104, 348),
    ]);
    final rHamstring = _mirrorX(lHamstring, cx);

    // Calves Back
    final lCalfBack = _polygon(const [
      Offset(114, 390),
      Offset(98, 422),
      Offset(112, 472),
      Offset(132, 472),
      Offset(138, 416),
    ]);
    final rCalfBack = _mirrorX(lCalfBack, cx);

    return {
      MuscleRegion.upperTraps: [trapsBack],
      MuscleRegion.middleBack: [lMidBack, rMidBack],
      MuscleRegion.rearDelts: [lRearDelt, rRearDelt],
      MuscleRegion.triceps: [lTricep, rTricep],
      MuscleRegion.forearms: [lForearmBack, rForearmBack],
      MuscleRegion.lats: [lLat, rLat],
      MuscleRegion.lowerBack: [lowerBack],
      MuscleRegion.abductors: [lAbductor, rAbductor],
      MuscleRegion.glutes: [lGlute, rGlute],
      MuscleRegion.hamstrings: [lHamstring, rHamstring],
      MuscleRegion.calves: [lCalfBack, rCalfBack],
    };
  }();

  // ── Background Body Silhouette ────────────────────────────────────────────

  static final Path frontSilhouette = _buildSilhouette(isFront: true);
  static final Path backSilhouette = _buildSilhouette(isFront: false);

  static Path _buildSilhouette({required bool isFront}) {
    final path = Path();
    // Head
    path.addOval(
      Rect.fromCenter(
        center: const Offset(150, 44),
        width: 48,
        height: 60,
      ),
    );

    // Left torso & limbs
    final half = Path()
      ..moveTo(140, 74)
      ..lineTo(140, 94) // Neck
      ..lineTo(106, 108) // Shoulder top
      ..lineTo(68, 142) // Deltoid out
      ..lineTo(74, 180) // Arm outer
      ..lineTo(64, 258) // Forearm outer
      ..lineTo(70, 302) // Wrist
      ..lineTo(68, 326) // Hand outer
      ..lineTo(80, 334) // Fingers
      ..lineTo(84, 296) // Wrist inner
      ..lineTo(98, 228) // Elbow inner
      ..lineTo(106, 172) // Armpit
      ..lineTo(108, 210) // Ribs
      ..lineTo(116, 252) // Hip
      ..lineTo(98, 310) // Quad outer
      ..lineTo(118, 374) // Knee
      ..lineTo(102, 422) // Calf outer
      ..lineTo(114, 474) // Ankle outer
      ..lineTo(110, 506) // Foot outer
      ..lineTo(130, 508) // Toes
      ..lineTo(132, 472) // Ankle inner
      ..lineTo(136, 412) // Calf inner
      ..lineTo(140, 372) // Knee inner
      ..lineTo(148, 260) // Crotch
      ..lineTo(150, 254); // Center groin

    path.addPath(half, Offset.zero);
    path.addPath(_mirrorX(half, 150.0), Offset.zero);
    return path;
  }

  /// Exact arbitrary-polygon hit test for tap detection.
  /// Returns the tapped [MuscleRegion] or null if tap missed all muscles.
  static MuscleRegion? hitTest({
    required Offset localPosition,
    Size widgetSize = const Size(viewBoxWidth, viewBoxHeight),
    required bool isFront,
  }) {
    // Transform local widget coordinates to 300x520 viewBox coordinates
    final scaleX = widgetSize.width / viewBoxWidth;
    final scaleY = widgetSize.height / viewBoxHeight;
    final scale = math.min(scaleX, scaleY);

    if (scale <= 0) return null;

    final offsetX = (widgetSize.width - (viewBoxWidth * scale)) / 2.0;
    final offsetY = (widgetSize.height - (viewBoxHeight * scale)) / 2.0;

    final viewBoxX = (localPosition.dx - offsetX) / scale;
    final viewBoxY = (localPosition.dy - offsetY) / scale;
    final point = Offset(viewBoxX, viewBoxY);

    final regionMap = isFront ? frontRegionPaths : backRegionPaths;

    for (final entry in regionMap.entries) {
      for (final path in entry.value) {
        if (path.contains(point)) {
          return entry.key;
        }
      }
    }
    return null;
  }
}
