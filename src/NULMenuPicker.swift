import SwiftUI

/// Nuul's compact menu picker: a flat value label with the platform's
/// disclosure affordance, rather than a bordered pop-up control.
struct NULMenuPicker<Selection: Hashable, ItemLabel: View>: View {
    private let title: LocalizedStringKey
    @Binding private var selection: Selection
    private let options: [Selection]
    private let label: (Selection) -> ItemLabel
    private let showsTitle: Bool

    init(
        _ title: LocalizedStringKey,
        selection: Binding<Selection>,
        options: [Selection],
        showsTitle: Bool = true,
        label: @escaping (Selection) -> ItemLabel
    ) {
        self.title = title
        self._selection = selection
        self.options = options
        self.showsTitle = showsTitle
        self.label = label
    }

    var body: some View {
        Menu {
            ForEach(options.indices, id: \.self) { index in
                let option = options[index]
                Button {
                    selection = option
                } label: {
                    label(option)
                }
                .accessibilityAddTraits(option == selection ? .isSelected : [])
            }
        } label: {
            HStack(spacing: Nuul.Spacing.medium) {
                if showsTitle {
                    Text(title)
                        .foregroundStyle(Nuul.itemSecondaryText)
                    Spacer(minLength: Nuul.Spacing.medium)
                }

                label(selection)
                    .lineLimit(1)
                    .font(Nuul.Typography.body)
                    .foregroundStyle(Nuul.itemSecondaryText)
            }
            .frame(minHeight: Nuul.Layout.controlHeight, alignment: .leading)
            .padding(.horizontal, Nuul.Spacing.medium)
            .contentShape(.rect(cornerRadius: Nuul.Radius.control))
        }
        .menuStyle(.borderlessButton)
        .accessibilityLabel(Text(title))
        .fixedSize(horizontal: true, vertical: false)
    }
}
