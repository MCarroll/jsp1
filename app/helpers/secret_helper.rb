module SecretHelper
  def blur_secret(content, blur: "blur-sm")
    id = ["secret", SecureRandom.hex(10)].join("_")

    tag.div class: "inline-block relative" do
      check_box_tag(nil, nil, false, id: id, class: "hidden peer") +
        tag.div(content, class: "blur-sm peer-checked:blur-none") +
        label_tag(id, class: "absolute inset-0 text-center peer-checked:hidden") do
          tag.div t("reveal"), class: "btn btn-secondary btn-xs"
        end
    end
  end
end
