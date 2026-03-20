from django.db import models


class ServiceCategory(models.Model):
    category_name = models.CharField(max_length=255)

    class Meta:
        db_table = 'service_categories'
        managed = False

    def __str__(self):
        return self.category_name


class Service(models.Model):
    category = models.ForeignKey(ServiceCategory, on_delete=models.CASCADE, related_name='services')
    service_name = models.CharField(max_length=255)
    base_price = models.DecimalField(max_digits=10, decimal_places=2)

    class Meta:
        db_table = 'services'
        managed = False

    def __str__(self):
        return self.service_name
