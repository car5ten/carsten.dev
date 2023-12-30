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
            resourcePaths: ["Resources/BasicTheme/styles.css", "Resources/fonts/timeburner/timeburnernormal.ttf", "Resources/fonts/timeburner/timeburnerbold.ttf", "Resources/fonts/geist/Geist-Regular.otf"]
        )
    }
}


private struct LandingPageHTMLFactory<Site: Website>: HTMLFactory {

    func makeIndexHTML(for index: Index,
                       context: PublishingContext<Site>) throws -> HTML {
        _ = context.markdownParser.parse(index.body.html)
        return HTML(
            .lang(context.site.language),
            .head(for: index, on: context.site),
            .body {
                SiteHeader(context: context, selectedSelectionID: nil)
                MainContainer {
                    index.body
                }
                SiteFooter()
            }
        )
    }

    func makeSectionHTML(for section: Section<Site>,
                         context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: section, on: context.site),
            .body {
                SiteHeader(context: context, selectedSelectionID: section.id)
                Wrapper {
                    H1(section.title)
                    ItemList(items: section.items, site: context.site)
                }
                SiteFooter()
            }
        )
    }

    func makeItemHTML(for item: Item<Site>,
                      context: PublishingContext<Site>) throws -> HTML {
        HTML()
    }

    func makePageHTML(for page: Page,
                      context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site),
            .body {
                SiteHeader(context: context, selectedSelectionID: nil)
                Wrapper(page.body)
                SiteFooter()
            }
        )
    }

    func makeTagListHTML(for page: TagListPage,
                         context: PublishingContext<Site>) throws -> HTML? {
        HTML()
    }

    func makeTagDetailsHTML(for page: TagDetailsPage,
                            context: PublishingContext<Site>) throws -> HTML? {
        HTML()
    }
}

private struct Wrapper: ComponentContainer {
    @ComponentBuilder var content: ContentProvider

    var body: Component {
        Div(content: content).class("wrapper")
    }
}

private struct MainContainer: ComponentContainer {
    @ComponentBuilder var content: ContentProvider

    var body: Component {
        Div(content: content).class("main-container")
    }
}

private struct SiteHeader<Site: Website>: Component {
    var context: PublishingContext<Site>
    var selectedSelectionID: Site.SectionID?

    var body: Component {
        Header {
            Wrapper {
                Div {
                    Div {
                        let left = context.site.name.split(separator: ".").first!
                        let leftEndIndex = context.site.name.range(of: left)!.upperBound
                        let right = context.site.name[leftEndIndex ..< context.site.name.endIndex]
                        Link(String(left), url: "/")
                            .class("left")
                        Link(String(right), url: "/")
                            .class("right")
                    }
                    .class("site-name")

                    if Site.SectionID.allCases.count > 0 {
                        navigation
                    }
                }
                .class("header-grid")
            }
        }
    }

    private var navigation: Component {
        Navigation {
            List(Site.SectionID.allCases) { sectionID in
                let section = context.sections[sectionID]

                return Link(section.title,
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
                H1(Link(item.title, url: item.path.absoluteString))
                ItemTagList(item: item, site: site)
                Paragraph(item.description)
            }
        }
        .class("item-list")
    }
}

private struct ItemTagList<Site: Website>: Component {
    var item: Item<Site>
    var site: Site

    var body: Component {
        List(item.tags) { tag in
            Link(tag.string, url: site.path(for: tag).absoluteString)
        }
        .class("tag-list")
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

