from rest_framework import serializers

from .models import (
    Category,
    Brand,
    Product,
    VariantOption,
    VariantOptionValue,
    ProductVariant,
    ProductImage,
    ProductQuestion,
    ProductReview,
)


# =========================================================
# Brand
# =========================================================

class BrandSerializer(serializers.ModelSerializer):

    category = serializers.StringRelatedField()

    class Meta:

        model = Brand

        fields = [
            'id',
            'name',
            'category', 
            'slug',
            'is_active',
            'created_at',
            'updated_at',
        ]

        read_only_fields = [
            'id',
            'slug',
            'created_at',
            'updated_at',
        ]


# =========================================================
# Category
# =========================================================

class CategorySerializer(serializers.ModelSerializer):

    brands = BrandSerializer(
        many=True,
        read_only=True 
    )
    subcategories = serializers.SerializerMethodField()

    class Meta:
        model = Category

        fields = [
            'id',
            'name',
            'slug',
            'image',
            'brands',
            'subcategories',
            'is_active',
            'is_featured',
            'created_at',
            'updated_at',
        ]

        read_only_fields = [
            'id',
            'slug',
            'brands',
            'subcategories',
            'created_at',
            'updated_at',
        ]

    def get_subcategories(self, obj):

        subcategories = Category.objects.filter(
            parent=obj,
            is_active=True
        )

        return CategorySerializer(
            subcategories,
            many=True
        ).data
    
    



# =========================================================
# Variant Option
# =========================================================

class VariantOptionSerializer(
    serializers.ModelSerializer
):

    class Meta:

        model = VariantOption

        fields = [
            'id',
            'name',
            'created_at',
            'updated_at',
        ]

        read_only_fields = [
            'id',
            'created_at',
            'updated_at',
        ]


# =========================================================
# Variant Option Value
# =========================================================

class VariantOptionValueSerializer(
    serializers.ModelSerializer
):

    class Meta:

        model = VariantOptionValue

        fields = [
            'id',
            'option',
            'value',
            'created_at',
            'updated_at',
        ]

        read_only_fields = [
            'id',
            'created_at',
            'updated_at',
        ]


# =========================================================
# Product Image
# =========================================================

class ProductImageSerializer(
    serializers.ModelSerializer
):

    class Meta:

        model = ProductImage

        fields = [
            'id',
            'variant',
            'image',
            'alt_text',
            'is_primary',
            'display_order',
            'created_at',
            'updated_at',
        ]

        read_only_fields = [
            'id',
            'alt_text',
            'created_at',
            'updated_at',
        ]


# =========================================================
# Product Variant
# =========================================================

class ProductVariantSerializer(
    serializers.ModelSerializer
):

    options = serializers.PrimaryKeyRelatedField(
        many=True,
        queryset=VariantOptionValue.objects.all(),
        required=False
    )

    images = ProductImageSerializer(
        many=True,
        read_only=True
    )

    discounted_price = serializers.ReadOnlyField()

    class Meta:

        model = ProductVariant

        fields = [
            'id',
            'product',
            'sku',
            'options',
            'price',
            'discount_percentage',
            'discounted_price',
            'stock',
            'is_default',
            'is_active',
            'images',
            'created_at',
            'updated_at',
        ]

        read_only_fields = [
            'id',
            'sku',
            'discounted_price',
            'images',
            'created_at',
            'updated_at',
        ]

    def validate_price(self, value):

        if value <= 0:

            raise serializers.ValidationError(
                'Price must be greater than 0.'
            )

        return value

    def validate_discount_percentage(self, value):

        if value < 0 or value > 100:

            raise serializers.ValidationError(
                'Discount must be between 0 and 100%.'
            )

        return value

    def validate(self, data):

        options = data.get(
            'options',
            []
        )

        option_ids = [
            option_value.option_id
            for option_value in options
        ]

        if len(option_ids) != len(
            set(option_ids)
        ):

            raise serializers.ValidationError({
                'options':
                    'A variant cannot have multiple '
                    'values from the same option.'
            })

        return data

    def to_representation(
        self,
        instance
    ):

        data = super().to_representation(
            instance
        )

        data['options'] = [
            {
                'id': option_value.id,
                'option': option_value.option.name,
                'value': option_value.value,
            }
            for option_value
            in instance.options.select_related(
                'option'
            ).all()
        ]

        return data


# =========================================================
# Product List Serializer
# =========================================================

class ProductListSerializer(
    serializers.ModelSerializer
):

    brand = serializers.StringRelatedField()

    category = serializers.StringRelatedField()

    old_price = serializers.SerializerMethodField()

    new_price = serializers.SerializerMethodField()

    saved_price = serializers.SerializerMethodField()

    discount_percentage = serializers.SerializerMethodField()

    image = serializers.SerializerMethodField()

    class Meta:

        model = Product

        fields = [
            'id',
            'name',
            'slug',
            'category', #needed for filtering. 
            'brand', #needed for filtering. 
            'key_feature', 
            'old_price',
            'new_price', 
            'saved_price', 
            'discount_percentage', 
            'image',
            'is_active',
            'is_featured',
        ]

    def get_default_variant(self, obj):

        return obj.variants.filter(
            is_active=True
        ).order_by(
            '-is_default',
            'price'
        ).first()

    def get_old_price(self, obj):

        variant = self.get_default_variant(obj)

        if not variant:
            return None

        return variant.price
    
    def get_new_price(self, obj):
    
        variant = self.get_default_variant(obj)

        if not variant:
            return None

        return variant.discounted_price
    
    def get_saved_price(self, obj):

        variant = self.get_default_variant(obj)

        if not variant:
            return None

        return variant.saved_price
    
    def get_discount_percentage(self, obj):
        variant = self.get_default_variant(obj)

        if not variant:
            return None
        
        return variant.discount_percentage

    def get_image(self, obj):

        variant = self.get_default_variant(obj)

        if not variant:
            return None

        image = variant.images.filter(
            is_primary=True
        ).first()

        if not image:

            image = variant.images.order_by(
                'display_order'
            ).first()

        if not image:
            return None

        request = self.context.get(
            'request'
        )

        if request:
            return request.build_absolute_uri(
                image.image.url
            )

        return image.image.url


# =========================================================
# Product Detail Serializer
# =========================================================

class ProductSerializer(
    serializers.ModelSerializer
):

    category = serializers.StringRelatedField()

    brand = serializers.StringRelatedField()

    variants = ProductVariantSerializer(
        many=True,
        read_only=True
    )

    class Meta:

        model = Product

        fields = [
            'id',
            'category',
            'brand',
            'name',
            'slug',
            'description',
            'specification',
            'is_active',
            'is_featured',
            'variants',
            'created_at',
            'updated_at',
        ]

        read_only_fields = [
            'id',
            'slug',
            'variants',
            'created_at',
            'updated_at',
        ]

    def validate_name(self, value):

        if not value.strip():

            raise serializers.ValidationError(
                'Product name cannot be empty.'
            )

        return value


# =========================================================
# Product Question
# =========================================================

class ProductQuestionSerializer(
    serializers.ModelSerializer
):

    class Meta:

        model = ProductQuestion

        fields = [
            'id',
            'product',
            'user',
            'question',
            'answer',
            'is_approved',
            'created_at',
            'updated_at',
        ]

        read_only_fields = [
            'id',
            'user',
            'answer',
            'is_approved',
            'created_at',
            'updated_at',
        ]


# =========================================================
# Product Review
# =========================================================

class ProductReviewSerializer(
    serializers.ModelSerializer
):

    class Meta:

        model = ProductReview

        fields = [
            'id',
            'product',
            'user',
            'rating',
            'review',
            'created_at',
            'updated_at',
        ]

        read_only_fields = [
            'id',
            'user',
            'created_at',
            'updated_at',
        ]