//
//imports
import UIKit
import SceneKit
import ARKit
import CoreLocation

class ViewController: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    var savesDouble = Float();
    let locationManager = CLLocationManager()
    var timer = Timer()
    var lat = String()
    var long = String()
    
    func setdouble(d:Float){
        savesDouble = d;
    }
    func getDouble() -> Float{
        return savesDouble;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // For use when the app is open & in the background
        locationManager.requestAlwaysAuthorization()
        
        // For use when the app is open
        //locationManager.requestWhenInUseAuthorization()
        
        // If location services is enabled get the users location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest // You can change the locaiton accuary here.
            locationManager.startUpdatingLocation()
        }
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
    }
    
    // Print out the location to the console
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print(location.coordinate)
        }
    }
    
    // If we have been deined access give the user the option to change it
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.denied) {
            showLocationDisabledPopUp()
        }
    }
    
    // Show the popup to the user if we have been deined access
    func showLocationDisabledPopUp() {
        let alertController = UIAlertController(title: "Background Location Access Disabled",
                                                message: "We need your location",
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if dotNodes.count >= 2 {
            //dotNodes = [SCNNode]()
        }
        if let touchLocation = touches.first?.location(in: sceneView) {
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            
            if let hitResult = hitTestResults.first {
                addDot(at: hitResult)
            }
        }
    }
    
    func addDot(at hitResult: ARHitTestResult) {
        let dotGeometry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        
        dotGeometry.materials = [material]
        
        let dotNode = SCNNode(geometry: dotGeometry)
        
        dotNode.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        dotNodes.append(dotNode)
        
        if dotNodes.count >= 2 {
            calculate(start:dotNodes[dotNodes.count - 2],end:dotNodes[dotNodes.count - 1])
        }
    }
    
    func calculate(start:SCNNode,end:SCNNode) {
        let lineNode = SCNGeometry.cylinderLine(from: start.position, to: end.position, segments: 5);
        sceneView.scene.rootNode.addChildNode(lineNode)
        let a = end.position.x - start.position.x
        let b = end.position.y - start.position.y
        let z = end.position.z - start.position.z
        let distance = sqrt(pow(a, 2) + pow(b, 2) + pow(z, 2))
        if(savesDouble == 0){
            setdouble(d: distance)
        }
        else{
            setdouble(d: getDouble()+distance)
        }
        let format = String(format: "%.4f", savesDouble)
        let formatted = Double(format)
        updateText(text: "\(formatted! * 100)cm", atPosition: end.position)
    }
    
    func updateText(text: String, atPosition position: SCNVector3) {
        textNode.removeFromParentNode()
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(position.x + 0.02, position.y - 0.01, position.z)
        textNode.scale = SCNVector3(0.0075, 0.0075, 0.0075)
        sceneView.scene.rootNode.addChildNode(textNode)
    }
}

