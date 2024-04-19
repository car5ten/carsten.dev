import Foundation
import Publish
import Plot
import Ink

// This type acts as the configuration for your website.
struct CarstenDev: Website {
    enum SectionID: String, WebsiteSectionID {
        // Add the sections that you want your website to contain here:
        case career
        case me
    }

    struct ItemMetadata: WebsiteItemMetadata {
        // Add any site-specific metadata that you want to use here.
    }

    // Update these properties to configure your website:
    var url = URL(string: "https://carsten.dev")!
    var name = "carsten.dev"
    var description: String = "carsten.dev"
    var language: Language { .english }
    var imagePath: Path? { nil }
}

// This will generate your website using the built-in Foundation theme:
try CarstenDev().publish(withTheme: .basic,
                         deployedUsing: .gitHub("car5ten/car5ten.github.io", branch: "website"),
                         additionalSteps: [
                            .copyFiles(at: .init("Resources/pages"))
                         ])
