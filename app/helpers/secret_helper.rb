module SecretHelper
  def blur_secret(content, blur: "blur-sm")
    tag.div class: "inline-block relative" do
      tag.span(content, class: "font-mono whitespace-pre-wrap #{blur}") +
        tag.div(class: "absolute inset-0 text-center") do
          button_tag t("reveal"), class: "btn btn-secondary btn-small m-auto", onclick: "this.parentElement.previousElementSibling.classList.remove('#{blur}');this.remove()"
        end
    end
  end
end
