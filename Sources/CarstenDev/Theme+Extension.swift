//
//  File.swift
//
//
//  Created by Carsten Voß on 25.10.23.
//

import Publish
import Plot

extension Theme {

    static var basic: Self {
        Theme(
            htmlFactory: LandingPageHTMLFactory(),
            resourcePaths: ["Resources/BasicTheme/styles.css",
                            "Resources/fonts/geist/Geist-Bold.otf",
                            "Resources/fonts/geist/Geist-Medium.otf",
                            "Resources/fonts/geist/Geist-Regular.otf",
                           ]
        )
    }
}

private struct LandingPageHTMLFactory<Site: Website>: HTMLFactory {

    enum ThemeError: Error {
        case unknownWebsiteSectionID
    }

    func head(index: Location, context: PublishingContext<Site>) -> Node<HTML.DocumentContext> {
        let location = index
        let site = context.site
        var title = location.title

        if title.isEmpty {
            title = site.name
        } else {
            title.append(" | " + site.name)
        }

        var description = location.description

        if description.isEmpty {
            description = site.description
        }

        return .head(
            .encoding(.utf8),
            .siteName(site.name),
            .url(site.url(for: location)),
            .title(title),
            .description(description),
            .twitterCardType(location.imagePath == nil ? .summary : .summaryLargeImage),
            .stylesheet(Path("/styles.css")),
            .viewport(.accordingToDevice),
            .unwrap(site.favicon, { .favicon($0) }),
            .unwrap(location.imagePath ?? site.imagePath, { path in
                let url = site.url(for: path)
                return .socialImageLink(url)
            })
        )

    }

    func makeIndexHTML(for index: Index,
                       context: PublishingContext<Site>) throws -> HTML {
        return HTML(
            .lang(context.site.language),
            head(index: index, context: context),
            .body {
                SiteHeader(context: context, selectedSelectionID: nil)
                Wrapper {
                    Div(index.body).class("main")
                }
                SiteFooter()
            }
        )
    }

    func makeSectionHTML(for section: Section<Site>,
                         context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            head(index: section, context: context),
            .body {
                SiteHeader(context: context, selectedSelectionID: section.id)
                if case .tldr = section.id as! CarstenDev.SectionID, let first = section.items.first {
                    Wrapper {
                        first.body
                    }
                } else {
                    Wrapper {
                        ItemList(items: section.items, site: context.site)
                    }
                }
                SiteFooter()
            }
        )
    }

    func makeItemHTML(for item: Item<Site>,
                      context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            head(index: item, context: context),
            .body(
                .class("item-page"),
                .components {
                    SiteHeader(context: context, selectedSelectionID: item.sectionID)
                    Wrapper {
                        Article {
                            Div(item.content.body).class("content")
                        }
                    }
                    SiteFooter()
                }
            )
        )
    }

    func makePageHTML(for page: Page,
                      context: PublishingContext<Site>) throws -> HTML {
        HTML()
    }

    func makeTagListHTML(for page: TagListPage,
                         context: PublishingContext<Site>) throws -> HTML? {
        nil
    }

    func makeTagDetailsHTML(for page: TagDetailsPage,
                            context: PublishingContext<Site>) throws -> HTML? {
        nil
    }
}

private struct Wrapper: ComponentContainer {
    @ComponentBuilder var content: ContentProvider

    var body: Component {
        Div(content: content).class("wrapper")
    }
}

private struct SiteHeader<Site: Website>: Component {
    var context: PublishingContext<Site>
    var selectedSelectionID: Site.SectionID?

    var body: Component {
        Header {
            Link(context.site.name, url: "/")
                .class("title")
            if Site.SectionID.allCases.count > 0 {
                H2 {
                    navigation
                }
            }
        }
    }

    private var navigation: Component {
        Navigation {
            List(Site.SectionID.allCases) { sectionID in
                let section = context.sections[sectionID]
                return Link(section.title.lowercased(),
                            url: section.path.absoluteString
                )
                .class(sectionID == selectedSelectionID ? "selected" : "")
            }
        }
    }
}

private struct ItemList<Site: Website>: Component {
    var items: [Item<Site>]
    var site: Site

    var body: Component {
        List(items) { item in
            Article {
                item.body
            }
        }
        .class("item-list")
    }
}

private struct SiteFooter: Component {
    var body: Component {
        Footer {
            Paragraph {
                Text("Generated using ")
                Link("Publish", url: "https://github.com/johnsundell/publish")
            }
        }
    }
}
