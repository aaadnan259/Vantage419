import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:vantage419/features/map/utils/map_camera_animator.dart';

class FakeMapCamera extends Fake implements MapCamera {
  @override
  final LatLng center;
  @override
  final double zoom;

  FakeMapCamera({required this.center, required this.zoom});
}

class FakeMapController extends Fake implements MapController {
  MapCamera _camera;
  final List<({LatLng center, double zoom})> moveCalls = [];

  FakeMapController(this._camera);

  @override
  MapCamera get camera => _camera;

  @override
  bool move(LatLng center, double zoom, {Offset? offset, String? id}) {
    moveCalls.add((center: center, zoom: zoom));
    _camera = FakeMapCamera(center: center, zoom: zoom);
    return true;
  }
}

void main() {
  testWidgets('MapCameraAnimator animates camera', (tester) async {
    final camera = FakeMapCamera(center: const LatLng(0, 0), zoom: 10);
    final controller = FakeMapController(camera);

    final animator = MapCameraAnimator(vsync: const TestVSync());

    animator.animateTo(controller, const LatLng(10, 10), 20);

    // Initial state
    expect(controller.moveCalls, isEmpty);

    // Start animation (pump one frame to initialize start time)
    await tester.pump();

    // Advance animation - 600ms (halfway)
    await tester.pump(const Duration(milliseconds: 600));

    expect(controller.moveCalls, isNotEmpty);
    final midCall = controller.moveCalls.last;

    // Check that we moved somewhat
    // At 600ms + initial frame, we are slightly past halfway.
    expect(midCall.center.latitude, closeTo(5, 0.5));
    expect(midCall.zoom, closeTo(15, 0.5));

    // Finish animation - another 700ms to be sure
    await tester.pump(const Duration(milliseconds: 700));

    final lastCall = controller.moveCalls.last;
    expect(lastCall.center.latitude, closeTo(10, 0.001));
    expect(lastCall.center.longitude, closeTo(10, 0.001));
    expect(lastCall.zoom, closeTo(20, 0.001));

    animator.dispose();
  });
}
