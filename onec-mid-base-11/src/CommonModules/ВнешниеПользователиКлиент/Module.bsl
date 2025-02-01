///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

// @strict-types


#Область ПрограммныйИнтерфейс

// См. ВнешниеПользователи.ТекущийВнешнийПользователь.
Функция ТекущийВнешнийПользователь() Экспорт
	
	Возврат ПользователиСлужебныйКлиентСервер.ТекущийВнешнийПользователь(
		ПользователиКлиент.АвторизованныйПользователь());
	
КонецФункции

#КонецОбласти
