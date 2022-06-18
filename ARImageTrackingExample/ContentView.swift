//
//  ContentView.swift
//  ARImageTrackingExample
//
//  Created by Vitor Grechi Kuninari on 16/06/2022.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView: View {
    var body: some View {
        ARViewContainer()
            .edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    let arView = ARView(frame: .zero)
    
    func makeUIView(context: Context) -> ARView {
        let configuration = ARImageTrackingConfiguration()
        
        if let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) {
            configuration.isAutoFocusEnabled = true
            configuration.trackingImages = referenceImages
            configuration.maximumNumberOfTrackedImages = 12
        } else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        arView.session.delegate = context.coordinator
        arView.session.run(configuration)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    class Coordinator: NSObject, ARSessionDelegate {
        let parent: ARViewContainer
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            for anchor in anchors {
                guard let imageAnchor = anchor as? ARImageAnchor else { return }
                if let imageName = imageAnchor.name {
                    let anchorEntity = AnchorEntity(anchor: imageAnchor)
                    let scene = try! Experience.loadBox()
                    if let entity = scene.findEntity(named: imageName) {
                        entity.position = SIMD3(0, 0.05, 0)
                        anchorEntity.addChild(entity)
                        parent.arView.scene.addAnchor(anchorEntity)
                    }
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
