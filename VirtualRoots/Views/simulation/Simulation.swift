//
//  Camara.swift
//  VirtualRoots
//
//  Created by ADMIN UNACH on 06/03/24.
//

import Foundation
import SwiftUI
import RealityKit
import ARKit

struct SimulationRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = SimulationController
    
    @Binding var navigationPath: NavigationPath
    
    func makeUIViewController(context: Context) -> SimulationController {
        let controller = SimulationController()
        controller.dismiss = {
            if !self.navigationPath.isEmpty {
                self.navigationPath.removeLast()
                controller.stopSimulation()
            }
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: SimulationController, context: Context) {
        print("updated")
    }
}

class SimulationController: UIViewController {
    var arView: SimulationCamera = SimulationCamera()
    var dismiss: (() -> Void)?
    
    var simulation: VRSimulation?
    var timer: Timer?
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        arView.session.run(config)
        
        // Añadir el reconocedor de toques
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapDetected))
        arView.addGestureRecognizer(tapGestureRecognizer)
        
        let swipeGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(goBack))
        swipeGestureRecognizer.edges = .left
        arView.addGestureRecognizer(swipeGestureRecognizer)
        
        arView.plantTable.vIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(displayPlants)))
        
        arView.varTable.vIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(displayVariables)))
        arView.varTable.waterSlider.addTarget(self, action: #selector(waterSliderChanged), for: .valueChanged)
        arView.varTable.sunSlider.addTarget(self, action: #selector(sunSliderChanged), for: .valueChanged)
        
        arView.timeTable.vIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(displayTime)))
        arView.timeTable.slider.addTarget(self, action: #selector(timeSliderChanged), for: .valueChanged)
        arView.timeTable.vTime.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeTimeFormat)))
        
        arView.resizeTable.vIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(displayResize)))
        
        view = arView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        simulation = VRSimulation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        stopSimulation()
        simulation?.end()
        simulation = nil
    }
    
    @objc func tapDetected(sender: UITapGestureRecognizer) {
        let touchLocation = sender.location(in: arView)
        let hitTestResult = arView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        
        guard let firstResult = hitTestResult.first else { return }
        let anchor = AnchorEntity(world: firstResult.worldTransform)
        
        guard let modelEntity = try? ModelEntity.loadModel(named: "grownCacao.usdz") else { return }
        
        modelEntity.scale = SIMD3<Float>(repeating: Float(arView.resizeTable.slider.value))
        anchor.addChild(modelEntity)
        arView.scene.addAnchor(anchor)
        
        if simulation?.isSimulating ?? true == false { startSimulation() }
        
        print("You are tapping")
    }
    
    fileprivate func stopSimulation() {
        simulation?.isSimulating = false
        timer?.invalidate()
        timer = nil
    }
    
    private func startSimulation() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(simulating), userInfo: nil, repeats: true)
    }
    
    @objc fileprivate func simulating() {
        DispatchQueue.global(qos: .background).async {
            self.simulation?.start()
            DispatchQueue.main.async {
                //self.label.text = self.label.text == "WORLD" ? "HELLO" : "WORLD"
            }
        }
    }
    
    @objc func goBack(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .recognized {
            dismiss?()
        }
    }
    
    @objc private func displayPlants() {
        let table = arView.plantTable
        
        if arView.varTable.isDisplayed { displayPlants() }
        
        if table.isDisplayed {
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0, animations: {
                table.goBack()
            }, completion: { _ in
                self.startSimulation()
            })
        } else {
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0, animations: {
                table.expand()
            }, completion: { _ in
                self.stopSimulation()
                table.displayContent()
            })
        }
    }
    
    @objc private func displayVariables() {
        let table = arView.varTable
        
        if arView.plantTable.isDisplayed { displayPlants() }
        
        if table.isDisplayed {
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0, animations: {
                table.goBack()
            }, completion: { _ in
                self.startSimulation()
            })
        } else {
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0, animations: {
                table.expand()
            }, completion: { _ in
                self.stopSimulation()
                table.displayContent()
            })
        }
    }
    
    @objc private func displayResize() {
        let table = arView.resizeTable
        
        if table.isDisplayed {
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0, animations: {
                table.goBack()
            }, completion: { _ in
                self.startSimulation()
            })
        } else {
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0, animations: {
                table.expand()
            }, completion: { _ in
                self.stopSimulation()
                table.displayContent()
            })
        }
    }
    
    @objc private func displayTime() {
        let table = arView.timeTable
        
        if table.isDisplayed {
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0, animations: {
                table.goBack()
            }, completion: { _ in
                self.startSimulation()
            })
        } else {
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0, animations: {
                table.expand()
            }, completion: { _ in
                self.stopSimulation()
                table.displayContent()
            })
        }
    }
    
    @objc private func waterSliderChanged() {
        arView.varTable.lblWater.text = "\(Int(arView.varTable.waterSlider.value)) ml"
    }
    
    @objc private func sunSliderChanged() {
        arView.varTable.lblSun.text = "\(Int(arView.varTable.sunSlider.value)) lu"
    }
    
    @objc private func timeSliderChanged() {
        let time: Int = Int(arView.timeTable.slider.value)
        
        arView.timeTable.lblTime.text = "\(time) \(arView.timeTable.timeFormat.rawValue)"
        
        switch arView.timeTable.timeFormat {
        case .SEG: simulation?.framesPerSecond = CGFloat(time)
        case .WEEK: simulation?.framesPerSecond = CGFloat(time) * 60.0 * 60.0 * 24.0 * 7.0
        case .MONTH: simulation?.framesPerSecond = CGFloat(time) * 60.0 * 60.0 * 24.0 * 7.0 * 4.0
        case .YEAR: simulation?.framesPerSecond = CGFloat(time) * 60.0 * 60.0 * 24.0 * 7.0 * 4.0 * 12.0
        }
        
        
    }
    
    @objc private func changeTimeFormat() {
        switch arView.timeTable.timeFormat {
        case .SEG: arView.timeTable.timeFormat = .WEEK
        case .WEEK: arView.timeTable.timeFormat = .MONTH
        case .MONTH: arView.timeTable.timeFormat = .YEAR
        case .YEAR: arView.timeTable.timeFormat = .SEG
        }
        print("time changed")
        timeSliderChanged()
    }
}

class SimulationCamera: ARView {
    
    required convenience init(frame frameRect: CGRect) {
        self.init()
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        self.layer.zPosition = -1
        
        initComponents()
    }
    
    private func initComponents() {
        addSubview(plantTable)
        addSubview(varTable)
        addSubview(resizeTable)
        addSubview(timeTable)
    }
    
    let plantTable: VPlantTable = VPlantTable()
    let varTable: VariableTable = VariableTable()
    let resizeTable: ResizeTable = ResizeTable()
    let timeTable: TimeTable = TimeTable()
}

class TableView: UIView {
    fileprivate var components: [UIView] = []
    
    var minFrame: CGRect { CGRect() }
    var maxFrame: CGRect { CGRect() }
    var isDisplayed: Bool = false
    
    let vIcon: UIView = UIView()
    let icon: UIImageView
    
    init(icon: UIImageView) {
        self.icon = icon
        super.init(frame: .zero)
        
        frame = minFrame
        
        initComponents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func expand() {
        frame = maxFrame
    }
    
    fileprivate func goBack() {
        frame = minFrame
        removeContent()
    }
    
    fileprivate func initComponents() {
        vIcon.backgroundColor = .clear
        vIcon.addSubview(icon)
        
        addSubview(vIcon)
    }
    fileprivate func displayContent() {
        isDisplayed = true
        
        components.forEach({ addSubview($0) })
    }
    fileprivate func removeContent() {
        isDisplayed = false
        
        components.forEach({ $0.removeFromSuperview() })
    }
}

class VariableTable: TableView {
    
    override var minFrame: CGRect { CGRect(x: 734, y: 90, width: 100, height: 100) }
    override var maxFrame: CGRect { CGRect(x: 194, y: 90, width: 640, height: 733) }
    
    init() {
        super.init(icon: UIImageView(image: UIImage(systemName: "slider.horizontal.below.sun.max")))
        
        backgroundColor = UIColor(hex: "3f433e").withAlphaComponent(0.8)
        layer.cornerRadius = 10.0
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func expand() {
        super.expand()
        vIcon.frame = CGRect(origin: CGPoint(x: 270, y: 0), size: icon.frame.size)
    }
    
    override func goBack() {
        super.goBack()
        vIcon.frame = CGRect(origin: .zero, size: icon.frame.size)
    }
    
    override func initComponents() {
        icon.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        icon.tintColor = .white
        vIcon.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: icon.frame.size)
        super.initComponents()
        
        waterIcon.image = UIImage(named: "water")
        waterIcon.frame = CGRect(x: 49, y: 110, width: 60, height: 80)
        components.append(waterIcon)
        
        waterSlider.frame = CGRect(x: 160, y: 150, width: 338, height: 16)
        waterSlider.minimumValue = 0.0
        waterSlider.maximumValue = 100.0
        waterSlider.value = 25.0
        waterSlider.tintColor = UIColor(hex: "d4eda9")
        components.append(waterSlider)
        
        lblWater.frame = CGRect(x: 524, y: 139, width: 93, height: 38)
        lblWater.text = "\(Int(waterSlider.value)) ml"
        lblWater.backgroundColor = UIColor(hex: "98ce47")
        lblWater.textAlignment = .center
        lblWater.layer.cornerRadius = 20
        lblWater.clipsToBounds = true
        components.append(lblWater)
        
        sunIcon.image = UIImage(named: "sun")
        sunIcon.frame = CGRect(x: 43, y: 252, width: 70, height: 70)
        components.append(sunIcon)
        
        sunSlider.frame = CGRect(x: 160, y: 271, width: 338, height: 16)
        sunSlider.minimumValue = 0.0
        sunSlider.maximumValue = 100.0
        sunSlider.value = 50.0
        sunSlider.tintColor = UIColor(hex: "e9f6d1")
        components.append(sunSlider)
        
        lblSun.frame = CGRect(x: 524, y: 250, width: 93, height: 38)
        lblSun.text = "\(Int(sunSlider.value)) lu"
        lblSun.backgroundColor = UIColor(hex: "B7E076")
        lblSun.textAlignment = .center
        lblSun.layer.cornerRadius = 20
        lblSun.clipsToBounds = true
        components.append(lblSun)
        
        dirtIcon.image = UIImage(named: "dirt")
        dirtIcon.frame = CGRect(x: 39, y: 390, width: 80, height: 87.07)
        components.append(dirtIcon)
        
        dirtContainer.frame = CGRect(x: 161, y: 379, width: 456, height: 120)
        dirtContainer.backgroundColor = UIColor(hex: "3d4b3d")
        dirtContainer.layer.cornerRadius = 20
        components.append(dirtContainer)
        
        nutrientIcon.image = UIImage(named: "nutrient")
        nutrientIcon.frame = CGRect(x: 39, y: 556, width: 80, height: 67.42)
        components.append(nutrientIcon)
        
        nutrientContainer.frame = CGRect(x: 161, y: 526, width: 456, height: 120)
        nutrientContainer.backgroundColor = UIColor(hex: "3d4b3d")
        nutrientContainer.layer.cornerRadius = 20
        components.append(nutrientContainer)
    }
    
    let waterIcon: UIImageView = UIImageView()
    let waterSlider: UISlider = UISlider()
    let lblWater: UILabel = UILabel()
    
    let sunIcon: UIImageView = UIImageView()
    let sunSlider: UISlider = UISlider()
    let lblSun: UILabel = UILabel()
    
    let dirtIcon: UIImageView = UIImageView()
    let dirtContainer: UIView = UIView()
    let dirtIcons: [UIImageView] = []
    
    let nutrientIcon: UIImageView = UIImageView()
    let nutrientContainer: UIView = UIView()
    let nutrientIcons: [UIImageView] = []
}

class VPlantTable: TableView {
    override var minFrame: CGRect { CGRect(x: 0, y: 30, width: 170, height: 160) }
    override var maxFrame: CGRect { CGRect(x: 0, y: 30, width: 712, height: 160) }
    
    init() {
        super.init(icon: UIImageView(image: UIImage(named: "sheet_icon")))
        
        backgroundColor = UIColor(hex: "3f433e").withAlphaComponent(0.8)
        layer.cornerRadius = 10.0
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func expand() {
        super.expand()
        
        vIcon.frame = CGRect(origin: CGPoint(x: 590, y: 42), size: icon.frame.size)
        plusIcon.removeFromSuperview()
        icon.addSubview(minusIcon)
    }
    
    override func goBack() {
        super.goBack()
        
        vIcon.frame = CGRect(x: 35, y: 42, width: 100, height: 76.65)
        minusIcon.removeFromSuperview()
        icon.addSubview(plusIcon)
    }
    
    override func initComponents() {
        icon.frame = CGRect(x: 0, y: 0, width: 100, height: 76.65)
        vIcon.frame = CGRect(origin: CGPoint(x: 0, y: 30), size: icon.frame.size)
        super.initComponents()
        
        vIcon.frame = CGRect(x: 35, y: 42, width: 100, height: 76.65)
        
        plusIcon.image = UIImage(named: "plus_icon")
        plusIcon.frame = CGRect(x: 80, y: 57, width: 20, height: 20)
        icon.addSubview(plusIcon)

        minusIcon.image = UIImage(named: "minus_icon")
        minusIcon.frame = CGRect(x: 80, y: 67, width: 20, height: 4)
    }
    
    let plusIcon: UIImageView = UIImageView()
    let minusIcon: UIImageView = UIImageView()
}

class ResizeTable: TableView {
    override var minFrame: CGRect { CGRect(x: 0, y: 1027, width: 100, height: 100) }
    override var maxFrame: CGRect { CGRect(x: 0, y: 1027, width: 739, height: 100) }
    
    init() {
        super.init(icon: UIImageView(image: UIImage(named: "resize")))
        
        backgroundColor = UIColor(hex: "3f433e").withAlphaComponent(0.8)
        layer.cornerRadius = 10.0
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func expand() {
        super.expand()
        vIcon.frame = CGRect(x: 639, y: 0, width: 100, height: 100)
    }
    
    override func goBack() {
        super.goBack()
        vIcon.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: icon.frame.size)
    }
    
    override func initComponents() {
        icon.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        vIcon.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: icon.frame.size)
        super.initComponents()
        
        slider.frame = CGRect(x: 45, y: 35, width: 565, height: 30)
        slider.tintColor = UIColor(hex: "d4eda9")
        slider.minimumValue = 0.01
        slider.maximumValue = 0.1
        slider.value = 0.05
        components.append(slider)
    }
    
    let slider: UISlider = UISlider()
}

class TimeTable: TableView {
    override var minFrame: CGRect { CGRect(x: 0, y: 874, width: 100, height: 100) }
    override var maxFrame: CGRect { CGRect(x: 0, y: 874, width: 739, height: 100) }
    
    var timeFormat: Format = .SEG
    
    enum Format: String {
        case SEG = "seg"
        case WEEK = "week"
        case MONTH = "month"
        case YEAR = "year"
    }
    
    init() {
        super.init(icon: UIImageView(image: UIImage(systemName: "clock")))
        
        backgroundColor = UIColor(hex: "3f433e").withAlphaComponent(0.8)
        layer.cornerRadius = 10.0
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func expand() {
        super.expand()
        vIcon.frame = CGRect(x: 639, y: 0, width: 100, height: 100)
    }
    
    override func goBack() {
        super.goBack()
        vIcon.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: icon.frame.size)
    }
    
    override func initComponents() {
        icon.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        vIcon.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: icon.frame.size)
        super.initComponents()
        
        slider.frame = CGRect(x: 45, y: 35, width: 432, height: 30)
        slider.tintColor = UIColor(hex: "d4eda9")
        slider.minimumValue = 1.0
        slider.maximumValue = 10.0
        slider.value = 5.0
        components.append(slider)
        
        vTime.frame = CGRect(x: 506, y: 29, width: 105, height: 42)
        vTime.addSubview(lblTime)
        components.append(vTime)
        
        lblTime.frame = CGRect(x: 0, y: 0, width: 105, height: 42)
        lblTime.text = "\(slider.value) \(timeFormat)"
        lblTime.font = UIFont(name: "Plus Jakarta Sans", size: 15)
        lblTime.textColor = .black
        lblTime.textAlignment = .center
        lblTime.backgroundColor = UIColor(hex: "98ce47")
        lblTime.layer.cornerRadius = 15
        lblTime.clipsToBounds = true
        vTime.addSubview(lblTime)
    }
    
    let slider: UISlider = UISlider()
    let lblTime: UILabel = UILabel()
    let vTime: UIView = UIView()
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var isAddMode: Bool  // Estado proveniente de ContentView
    @Binding var deleteAll: Bool
    @Binding var modelScale: CGFloat
    @Binding var isLoading: Bool
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        // Configuraciones de la sesión de AR
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        arView.session.run(config)
        
        // Añadir el reconocedor de toques
        let tapGestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
        arView.addGestureRecognizer(tapGestureRecognizer)
        
//DispatchQueue.main.async {
            //       self.isLoading = false
            //   }
        
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        context.coordinator.isAddMode = isAddMode
        context.coordinator.deleteAll = deleteAll
        context.coordinator.modelScale = modelScale
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(arView: self, isAddMode: isAddMode, deleteAll: deleteAll, modelScale: modelScale)
    }

    class Coordinator: NSObject {
        var arViewContainer: ARViewContainer
        var isAddMode: Bool
        var deleteAll: Bool
        var modelScale: CGFloat
        var lastAnchor: AnchorEntity? // Referencia al último AnchorEntity añadido
        let plant: String = "grownCacaoTree.usdz"

        init(arView: ARViewContainer, isAddMode: Bool, deleteAll: Bool, modelScale: CGFloat) {
            self.arViewContainer = arView
            self.isAddMode = isAddMode
            self.deleteAll = deleteAll
            self.modelScale = modelScale
        }
        
        @objc func handleTap(sender: UITapGestureRecognizer) {
            guard let arView = sender.view as? ARView else { return }
            let touchLocation = sender.location(in: arView)
            
            let hitTestResults = arView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let firstResult = hitTestResults.first {
                if isAddMode {
                    // Modo añadir: crea y añade un nuevo anchor y modelo
                    let anchor = AnchorEntity(world: firstResult.worldTransform)
                    if let modelEntity = try? ModelEntity.loadModel(named: plant) {
                        modelEntity.scale = SIMD3<Float>(repeating: Float(modelScale))
                        anchor.addChild(modelEntity)
                        arView.scene.addAnchor(anchor)
                        // Guarda esta entidad de anclaje como la última añadida
                        lastAnchor = anchor
                    }
                } else {
                    // Modo mover: elimina el último modelo añadido
                    if let lastAnchor = lastAnchor {
                        arView.scene.removeAnchor(lastAnchor)
                    }
                    // Crea y añade un nuevo anchor y modelo
                    let newAnchor = AnchorEntity(world: firstResult.worldTransform)
                    if let newModelEntity = try? ModelEntity.loadModel(named: plant) {
                        newModelEntity.scale = SIMD3<Float>(x: 0.05, y: 0.05, z: 0.05)
                        newAnchor.addChild(newModelEntity)
                        arView.scene.addAnchor(newAnchor)
                        // Actualiza la referencia del último anchor añadido
                        self.lastAnchor = newAnchor
                    }
                }
                
                
            }
            if deleteAll {
                arView.scene.anchors.removeAll()
                deleteAll.toggle()
            }
        }
    }
}
